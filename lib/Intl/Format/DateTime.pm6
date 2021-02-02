use Intl::CLDR;
use Intl::UserLanguage;
use Intl::Format::DateTime::Formatters;
use Intl::Format::DateTime::FieldMeta;
grammar DateTimePattern        { ... } # Parses the skeleton patterns
class   DateTimePatternAction  { ... } # Compiles the above parse tree
class   DateTimeSkeletonAction { ... } # Compiles the parse tree, using skeleton data
sub     get-pattern            { ... } # A caching method
sub     pattern-replace        { ... } # Uses the pattern to combine with language data to produce the formatted text
sub     get-skeleton-pattern   { ... } # A caching method
class   SkeletonPatternDatum   { ... } # A structure for holding skeleton data


#| Formats a DateTime object into localized, human readable text
multi sub format-datetime(
        DateTime() $datetime,       #= The datetime to be formatted
        :$language = user-language, #= The locale to use (defaults to B<user-language>)
        :$length   = 'medium',      #= The formatting length (defaults to 'medium')
        --> Str
) is export(:DEFAULT) {

   #my \calendar = cldr{~$language}.dates.calendars{$datetime.calendar}; <-- When enabled by DateTime::Calendars
    my \calendar = cldr{~$language}.dates.calendars.gregorian;

    my \combo    := calendar.datetime-formats{$length}.pattern;
    my \time     := calendar.time-formats{    $length}.pattern;
    my \date     := calendar.date-formats{    $length}.pattern;
    my \datetime := combo.subst("'","",:g).subst:              # Technically, apostrophes should be parsed out formally
                                / \{ (0|1) \} /,               # {0} and {1} are replacement tokens
                                { $0 eq '0' ?? time !! date }, # 0 for time, 1 for date
                                :g;

    pattern-replace
            $datetime,
            get-pattern(datetime),
            $language,
            calendar;
}

#| Formats a DateTime object into localized, human readable text
multi sub format-datetime(
    DateTime()  $datetime,                 #= The datetime to be formatted
               :$language = user-language, #= The locale to use (defaults to B<user-language>)
    Str:D      :skeleton(:$like)!          #= The formatting pattern to approximate
    --> Str
) is export(:DEFAULT) {

    #my \calendar = cldr{~$language}.dates.calendars{$datetime.calendar}; <-- When enabled by DateTime::Calendars
    my \calendar = cldr{~$language}.dates.calendars.gregorian;

    # Todo, check for date/time elements separately
    # Todo, check for date/time elements separately
    # First, get the pattern we'll be using.
    my \datetime = best-pattern $like, calendar;



    pattern-replace
        $datetime,
        get-skeleton-pattern(datetime, $like, calendar),
        $language,
        calendar;
}


#| Formats a Date object into localized, human readable text (using only the data if time data is present)
multi sub format-date(
        Date() $datetime,           #= The date to be formatted (if passed DateTime, time is ignored)
        :$language = user-language, #= The locale to use (defaults to B<user-language>)
        :$length   = 'medium',      #= The formatting length (defaults to 'medium')
        --> Str
) is export(:DEFAULT) {

   #my \calendar = cldr{~$language}.dates.calendars{$datetime.calendar}; <-- When enabled by DateTime::Calendars
    my \calendar      = cldr{~$language}.dates.calendars.gregorian;
    my \date-pattern := calendar.date-formats{$length}.pattern;

    pattern-replace
            $datetime,
            get-pattern(date-pattern),
            $language,
            calendar;
}

#| Formats a DateTime object into localized, human readable text (using only the time data)
multi sub format-time(
        DateTime() $datetime,       #= The time to be formatted (date elements ignored)
        :$language = user-language, #= The locale to use (defaults to B<user-language>)
        :$length   = 'medium',      #= The formatting length (defaults to 'medium')
        --> Str
) is export(:DEFAULT) {

    #my \calendar = cldr{~$language}.dates.calendars{$datetime.calendar}; <-- When enabled by DateTime::Calendars
    my \calendar      = cldr{~$language}.dates.calendars.gregorian;
    my \time-pattern := calendar.time-formats{$length}.pattern;

    pattern-replace
            $datetime,
            get-pattern(time-pattern),
            $language,
            calendar;
}



#####################
# RELATIVE VERSIONS #
#####################
# These are really almost entirely different in calculation and formatting, but it makes sense
# as an option on the main subs.
#####################

multi sub format-datetime(
        DateTime() $datetime,       #= The datetime to be formatted
        :$language = user-language, #= The locale to use (defaults to B<user-language>)
        :$length   = 'medium',      #= The formatting length (defaults to 'medium')
        :relative-to($relative)     #= The datetime the relative time is calcuated from
        --> Str
) is export(:DEFAULT) {
    die "Relative option is NYI, sorry!";
    my $anchor;
    if $relative.isa(DateTime) {
        $anchor := $relative;
    } elsif $relative.isa(Instant) {

    }

}




#| Obtains a parsed version of a pattern to be used by the pattern-replace sub
sub get-pattern(Str() \str) is export(:manual) {
    state %cache;
    .return with %cache{str};
    %cache{str} := DateTimePattern.parse(str, :actions(DateTimePatternAction)).made;
}

sub get-skeleton-pattern(Str() \str, $skeleton, \calendar) is export(:manual) {
    state %cache;
    .return with %cache{"$skeleton|" ~ str};

    my $best          = best-pattern          $skeleton, calendar;
    my $skeleton-data = skeleton-pattern-data $skeleton;

    %cache{"$skeleton|" ~ str}
        := DateTimePattern.parse(str, :actions(DateTimeSkeletonAction.new: $skeleton-data)).made;
}

#| Replaces the dynamic elements of an (already parsed) pattern based on the given arguments.
sub pattern-replace($datetime, @pattern, $*language, $calendar) is export(:manual) {
    [~] do .isa(Str)
            ?? $_
            !! $_($calendar, $datetime, cldr{$*language}.dates.timezone-names )
    for @pattern
}









grammar DateTimePattern {
    token TOP                  {     <element>+     }
    proto token element        {         *          }
    token element:sym<literal> {      <text>+       }
    token element:sym<replace> { (<[a..zA..Z]>) $0* }
    proto token text           {         *          }
    token text:sym<apostrophe> {        \'\'        }
    token text:sym<literal>    {   <-[a..zA..Z']>+  }
    token text:sym<quoted>     {         \'           # apostrophes only allowed
                                <([<-[']>+||\'\']+)>  # if doubled, action reduces it
                                         \'         } # down to one
}

class DateTimePatternAction {
    method TOP                  ($/) { make $<element>.map(*.made)      }
    method element:sym<literal> ($/) { make $<text>.map(   *.made).join }
    method element:sym<replace> ($/) { make %formatters{$/}             }
    method text:sym<apostrophe> ($/) { make "'"                         }
    method text:sym<literal>    ($/) { make $/.Str                      }
    method text:sym<quoted>     ($/) { make $/.Str.subst("''","'")      }
}

#| Parse a DateTime pattern, replacing elements as needed.  May not be used abstractly.
class DateTimeSkeletonAction {
    has $.bones is required;
    method new              ($bones) { self.bless: :$bones              }
    method TOP                  ($/) { make $<element>.map(*.made)      }
    method element:sym<literal> ($/) { make $<text>.map(   *.made).join }
    method element:sym<replace> ($/) {
        my $meta = %fields{$/.Str};
        my $bone = $!bones[$meta.type];
        make %formatters{$bone.symbol || $/.Str}
    }
    method text:sym<apostrophe> ($/) { make "'"                         }
    method text:sym<literal>    ($/) { make $/.Str                      }
    method text:sym<quoted>     ($/) { make $/.Str.subst("''","'") }
}










# BEGIN SKELETON PATTERN PROCESSING



#| Calculates how different two skeleton patterns are (smaller is more similar)
sub skeleton-pattern-difference(\a, \b --> int) {
    use Intl::Format::DateTime::Constants;
    my int $difference = 0;
    for a<> Z b<> -> ($a, $b) {
        if    $a.distance == 0 && $b.distance != 0 { $difference += EXTRA   }
        elsif $a.distance != 0 && $b.distance == 0 { $difference += MISSING }
        else                 { $difference += abs $a.distance - $b.distance }
    }
    $difference
}


class SkeletonPatternDatum {
    has Str $.symbol;
    has int $.distance;
}

sub skeleton-pattern-data($string) {
    state %cache;
    .return with %cache{$string};

    my @result  = Any xx 32;

    for $string.comb(/<[GyYuUrQqMLlwWdDfgEecabBhHKkjJCmsSAzZOvVXx]>/).join.match(/((.) $0*)/, :g) {
        my $meta = %fields{.Str};

        @result[$meta.type * 2] = .Str;
        @result[$meta.type * 2 + 1] = $meta.distance;
    }
    %cache{$string} =
        do for @result -> $symbol, $distance {
            SkeletonPatternDatum.new: :symbol($symbol // ''), :distance($distance // 0);
        }
}

sub best-pattern(\skeleton, \calendar) {
    my Str    $best       = '';
    my uint64 $best-score = 0xffffffff;
    my        $want       = skeleton-pattern-data skeleton;

    for calendar.datetime-formats.available-formats.keys {
        my $difference = skeleton-pattern-difference($want, skeleton-pattern-data $_);
        if $difference < $best-score {
            $best       = $_;
            $best-score = $difference
        }
    }
    calendar.datetime-formats.available-formats{$best};
}