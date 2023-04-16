use v6.d;
unit module Intl::Format::DateTime;

use DateTime::Timezones:ver<0.4.3>;
use Intl::CLDR:auth<zef:guifa>:ver<0.7.4+>;
use User::Language:auth<zef:guifa>:ver<0.5.1+>;
use Intl::LanguageTag:auth<zef:guifa>:ver<0.12.3+>;

sub     get-skeleton-pattern   { ... } # A caching method
sub     pattern-replace        { ... } # Uses the pattern to combine with language data to produce the formatted text

subset DateTimeFormatLength of Str where 'full' | 'long' | 'medium' | 'short';

# Not threadsafe, but unlikely to cause issue because misses will just run the generation code twice
# TODO: make properly threadsafe
my %cache;
use MONKEY-SEE-NO-EVAL;


#| Formats a DateTime object into localized, human readable text
multi sub format-datetime(
    DateTime()            $datetime = DateTime.now,  #= The datetime to be formatted
    LanguageTag()        :$language = user-language, #= The locale to use (defaults to B<user-language>)
    DateTimeFormatLength :$length   = 'medium',      #= The formatting length (defaults to 'medium')
    --> Str
) is export(:DEFAULT) {
    %cache{'DT' ~ $length ~ $language}
        andthen return .($datetime);

    local-datetime-formatter(:$language, :$length)
        andthen .($datetime);
}


#| Formats a Date object into localized, human readable text
multi sub format-date(
    Dateish()             $date     = DateTime.now,  #= The date to be formatted
    LanguageTag()        :$language = user-language, #= The locale to use (defaults to B<user-language>)
    DateTimeFormatLength :$length   = 'medium',      #= The formatting length (defaults to 'medium')
    --> Str
) is export(:DEFAULT) {
    %cache{'D' ~ $length ~ $language}
        andthen return .($date);

    local-date-formatter(:$language, :$length)
        andthen .($date);
}

#| Formats a DateTime object into localized, human readable text for time only
multi sub format-time(
    DateTime()            $time     = DateTime.now,  #= The datetime whose time is to be formatted
    LanguageTag()        :$language = user-language, #= The locale to use (defaults to B<user-language>)
    DateTimeFormatLength :$length   = 'medium',      #= The formatting length (defaults to 'medium')
    --> Str
) is export(:DEFAULT) {
    %cache{'T' ~ $length ~ $language}
        andthen return .($time);

    local-time-formatter(:$language, :$length)
        andthen .($time);
}

#| Uses a skeleton pattern to format a DateTime into human readable text
multi sub format-datetime(
    DateTime()     $datetime = DateTime.now,  #= The datetime to be formatted
    LanguageTag() :$language = user-language, #= The locale to use (defaults to B<user-language>)
    Str:D         :skeleton(:$like)!,         #= The formatting pattern to approximate
                  :$length                    #= The length of the pattern (ignored for skeleton calls)
    --> Str
) is export(:DEFAULT) {
    my $code := 'S' ~ $like ~ '-' ~ $language;

    %cache{$code}
        andthen return .($datetime);

    # Now handle the skeleton pattern replacement, which is a bit convoluted.
    # First, obtain the preset pattern that is closest to the request pattern:
    use Intl::Format::DateTime::Parsing::Skeletons;
    use Intl::Format::DateTime::Parsing::Grammar;
    use Intl::Format::DateTime::Parsing::SkeletonActions;

    my \calendar = cldr{~$language}.dates.calendars.gregorian;
    my \closest = best-pattern $like, calendar;

    # Next, parse that pattern but using the skeleton actions instead
    my $skeleton-data := skeleton-pattern-replace-data($like);

    %cache{$code} := datetime-formatter(closest, :$language, :$skeleton-data)
        andthen .($datetime);
}

sub local-datetime-formatter(LanguageTag() :$language, :$length, :skeleton($like)) {
    %cache{'DT' ~ $length ~ $language}
        andthen .return;

    my \calendar := cldr{~$language}.dates.calendars.gregorian; # TODO: add support for other calendars
    my \combo    := calendar.datetime-formats{$length}.pattern;
    my \time     := calendar.time-formats{    $length}.pattern;
    my \date     := calendar.date-formats{    $length}.pattern;
    my \datetime := combo.subst("'","",:g).subst:              # Technically, apostrophes should be parsed out formally
                                / \{ (0|1) \} /,               # {0} and {1} are replacement tokens
                                { $0 eq '0' ?? time !! date }, # 0 for time, 1 for date
                                :g;

    %cache{'DT' ~ $length ~ $language} := datetime-formatter(datetime, :$language)
}

sub local-date-formatter(LanguageTag() :$language, :$length, :skeleton($like)) is export {
    %cache{'D' ~ $length ~ $language}
        andthen .return;

    my \calendar := cldr{~$language}.dates.calendars.gregorian; # TODO: add support for other calendars
    my \date     := calendar.date-formats{    $length}.pattern;

    %cache{'D' ~ $length ~ $language} := datetime-formatter(date, :$language)
}

sub local-time-formatter(LanguageTag() :$language, :$length, :skeleton($like)) is export {
    %cache{'T' ~ $length ~ $language}
        andthen .return;

    my \calendar := cldr{~$language}.dates.calendars.gregorian; # TODO: add support for other calendars
    my \time     := calendar.time-formats{    $length}.pattern;

    %cache{'T' ~ $length ~ $language} := datetime-formatter(time, :$language)
}


#| Creates a DateTime formatter sub (compiled or in RakuAST) based on a pattern and language combination.
#| If you don't know the pattern, use local-datetime-formatter instead.
sub datetime-formatter($pattern, :$language, :$rast = False, :$skeleton-data?) is export(:expert) {
    my $node := format-datetime-rakuast($pattern, $language, $skeleton-data);
    use MONKEY-SEE-NO-EVAL;
    return $rast ?? $node !! (EVAL $node);
}

# This future proofs things.  Vanilla uses pure Raku code.
# NQP uses nqp to speed some processes up.  To use as a
# named argument, preface with |: `|compile-option`
constant compile-option = BEGIN %(
    ($*RAKU.compiler.name eq 'rakudo'
        ?? 'nqp'
        !! 'vanilla'
    ) => True );

sub format-datetime-rakuast($pattern, $language, $skeleton-data?) {
    use Intl::Format::DateTime::Util;
    use Intl::Format::DateTime::Parsing::Actions;
    use Intl::Format::DateTime::Parsing::SkeletonActions;
    use Intl::Format::DateTime::Parsing::Grammar;
    use experimental :rakuast;

    my $data = CLDR-Data.new($language);
    my $match;
    my @format-code;
    if $skeleton-data {
        $match  = DateTimePattern.parse($pattern, :actions(SkeletonActions));
        @format-code.append: $_.generate-code($data,$skeleton-data)<> for $match.made<>;
    } else {
        # Do things the simple way
        $match  = DateTimePattern.parse($pattern, :actions(DateTimePatternActions));
        @format-code.append: $_.generate-code($data)<> for $match.made<>;
    }
    # Every formatter has a variable $DATETIMETEMP1 available to use for temporary calculations.
    # To my knowledge only the w/Y formatters need more.  This will be renamed to just $DATETIMETEMP in
    # a future update.  The sub should read out as
    # sub format-datetime($datetime) {
    #     my sub transliterate($text) { ... }
    #     my $result = '';
    #     my $DATETIMETEMP1;
    #     [ code ]
    #     $result
    # }
    RakuAST::Sub.new(
        name => RakuAST::Name.from-identifier('format'),
        signature => RakuAST::Signature.new(
            parameters => (
                RakuAST::Parameter.new(
                    target => RakuAST::ParameterTarget::Var.new('$datetime')
                ),
            ),
        ),
        body => RakuAST::Blockoid.new( RakuAST::StatementList.new(
           |rast-transliterate($data.number-system, |compile-option),
            RakuAST::Statement::Expression.new(
                expression => RakuAST::VarDeclaration::Simple.new( :scope<my>,:name<$result>,
                    type => RakuAST::Type::Simple.new(RakuAST::Name.from-identifier('Str')),
                    initializer => RakuAST::Initializer::Assign.new(RakuAST::StrLiteral.new(''))
                )
            ),
            RakuAST::Statement::Expression.new(
                expression => RakuAST::VarDeclaration::Simple.new( :scope<my>,:name<$DATETIMETEMP1>,
                    type => RakuAST::Type::Simple.new(RakuAST::Name.from-identifier('Any')),
                )
            ),
            |@format-code,
            RakuAST::Statement::Expression.new( expression => RakuAST::Var::Lexical.new('$result') )
        ))
    )
}