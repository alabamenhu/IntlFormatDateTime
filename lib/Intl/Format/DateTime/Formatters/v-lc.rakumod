use v6.d;
unit module v-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;

# The 'V' formatter is the timezone ID formatter.  It is interpreted thus:
# 'V'    short timezone id (from CLDR)
# 'VV'   long time zone ID (the Olson ID)
# 'VVV'  The exemplar city, if it exists, else 'Etc/Unknown' exemplar city
# 'VVVV' Generic location format


constant Result    = RakuAST::Var::Lexical.new('$result');
constant Source    = RakuAST::Var::Lexical.new('$datetime');
constant Temp      = RakuAST::Var::Lexical.new('$DATETIMETEMP1');
constant Assign    = RakuAST::Infix.new(':=');
constant Concat    = RakuAST::Infix.new('~');
constant Plus      = RakuAST::Infix.new('+');
constant Minus     = RakuAST::Infix.new('-');
constant IntDivide = RakuAST::Infix.new('div');
constant IntMod    = RakuAST::Infix.new('mod');
constant Multiply  = RakuAST::Infix.new('*');
constant ExistsOr = RakuAST::Infix.new('//');
constant GetDay    = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('day'));
constant GetMonth  = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('month'));
constant GetYear   = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('year'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));
constant MaybeTimezone = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('olson-id'));
constant UseShortnames = RakuAST::Statement::Use.new(
                         module-name => RakuAST::Name.from-identifier-parts('Intl','Format','DateTime','Shortnames'));
constant UseMetazones = RakuAST::Statement::Use.new(
                         module-name => RakuAST::Name.from-identifier-parts('Intl','Format','DateTime','Metazones'));
constant UseMetazoneNames = RakuAST::Statement::Use.new(
                         module-name => RakuAST::Name.from-identifier-parts('Intl','Format','DateTime','MetazoneNames'));
constant UseExemplarCities = RakuAST::Statement::Use.new(
                         module-name => RakuAST::Name.from-identifier-parts('Intl','Format','DateTime','ExemplarCities'));



proto sub format-v($, $) is export { * }

multi sub format-v($,\data) {
    # The fallback here is v --> VVVV -> O, but VVVV falls back to OOOO, so we need to copy and paste in some code here
    use Intl::Format::DateTime::Formatters::O-uc;
    UseMetazoneNames,
    RakuAST::Statement::If.new(
        condition => RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::Call::Name.new(
                name => RakuAST::Name.from-identifier('metazone-name'),
                args => RakuAST::ArgList.new(
                    RakuAST::StrLiteral.new(data.language.Str),
                    Source,
                    RakuAST::IntLiteral.new(0), # short
                    RakuAST::IntLiteral.new(1)  # generic (no standard/daylight)
                )
            )
        ),
        then => RakuAST::Block.new(body=>RakuAST::Blockoid.new(RakuAST::StatementList.new(
            concat-to-result-stmt(Temp)
        ))),
        else => RakuAST::Block.new(body=>RakuAST::Blockoid.new(RakuAST::StatementList.new(
            UseExemplarCities,
            RakuAST::Statement::If.new(
                condition => RakuAST::ApplyInfix.new(
                    left => Temp,
                    infix => Assign,
                    right => RakuAST::Call::Name.new(
                        name => RakuAST::Name.from-identifier('exemplar-city'),
                        args => RakuAST::ArgList.new(
                            RakuAST::StrLiteral.new(data.language.Str),
                            Source
                        )
                    )
                ),
                then => RakuAST::Block.new(body => RakuAST::Blockoid.new(RakuAST::StatementList.new(
                    concat-to-result-stmt(
                        one-term-replace(
                            data.dates.timezone-names.region-format.generic,
                            '{0}',
                            Temp,
                        )
                    ),
                ))),
                else => RakuAST::Block.new(body => RakuAST::Blockoid.new(RakuAST::StatementList.new(
                    |format-O(1,data)
                )))
            )
        )))
    )
}
multi sub format-v(4,\data) {
    # Should return Etc/Unknown if it's not known but …that should already be handled by the timezone module
    use Intl::Format::DateTime::Formatters::V-uc;
    UseMetazoneNames,
    RakuAST::Statement::If.new(
        condition => RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::Call::Name.new(
                name => RakuAST::Name.from-identifier('metazone-name'),
                args => RakuAST::ArgList.new(
                    RakuAST::StrLiteral.new(data.language.Str),
                    Source,
                    RakuAST::IntLiteral.new(1), # long
                    RakuAST::IntLiteral.new(1)  # generic
                )
            )
        ),
        then => RakuAST::Block.new(body=>RakuAST::Blockoid.new(RakuAST::StatementList.new(
            concat-to-result-stmt(Temp) # no need to replace, long forms include "* Time"
        ))),
        else => RakuAST::Block.new(body => RakuAST::Blockoid.new(RakuAST::StatementList.new(
            |format-V(4,data)
        )))
    )
}


sub one-term-replace($haystack, $needle, $replace) {
    my $initial-offset = $haystack.index($needle) // die 'GMT replacement value malformed';
    my $final-offset = $initial-offset + $needle.chars;

    if $initial-offset == 0 {
        # Replace in the end
        return RakuAST::ApplyInfix.new(
            left  => $replace,
            infix => Concat,
            right => RakuAST::StrLiteral.new($haystack.substr($final-offset)),
        )
    } elsif $final-offset == $haystack.chars {
        # Replace at the beginning
        return RakuAST::ApplyInfix.new(
            left => RakuAST::StrLiteral.new($haystack.substr(0,$initial-offset)),
            infix => Concat,
            right => $replace
        )
    } else {
        # Replace in the middle
        # Replace in the end
        return RakuAST::ApplyInfix.new(
            left => RakuAST::StrLiteral.new($haystack.substr(0,$initial-offset)),
            infix => Concat,
            right => RakuAST::ApplyInfix.new(
                left  => $replace,
                infix => Concat,
                right => RakuAST::StrLiteral.new($haystack.substr($final-offset)),
            )
        )
    }
}
