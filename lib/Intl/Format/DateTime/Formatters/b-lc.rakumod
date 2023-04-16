use v6.d;
unit module b-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'b' formatter is the ᴀᴍ/ᴘᴍ formatter, but also includes values for midnight/noon.
#
# 'b', 'bb', and 'bbb' are identical, so specific versions are provided for
# 4 and 5, and then 1-3 is placed in a catch all.
#
# As not all languages use noon/midnight, a minor optimization is to only add
# them if needed, otherwise, functionality will be the same as the 'a' series.
#
# For future development: should am/pm only be shown at 12:00:00.0̅?
# CLDR documentation isn't clear.  Currently, we only look at hour/min.

constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');

# $result = $result ~ ($datetime.hour < 12
#   ?? day-periods.format.abbreviated.am
#   !! day-periods.format.abbreviated.pm
sub format-b(\width,\data) is export {
    my \rules = data.dates.day-period-rules.standard;

    my \terms = width > 4
        ?? data.calendar.day-periods.format.narrow
        !! width == 4
            ?? data.calendar.day-periods.format.wide
            !! data.calendar.day-periods.format.abbreviated;

    my $ternary := RakuAST::Ternary.new(
        condition => RakuAST::ApplyInfix.new(
            left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
            infix => RakuAST::Infix.new('<'),
            right => RakuAST::IntLiteral.new(720)
        ),
        then => RakuAST::StrLiteral.new(terms.am),
        else => RakuAST::StrLiteral.new(terms.pm)
    );

    if rules.noon.used {
        $ternary := RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
                infix => RakuAST::Infix.new('=='),
                right => RakuAST::IntLiteral.new(720)
            ),
            then => RakuAST::StrLiteral.new(terms.noon),
            else => $ternary
        )
    }

    if rules.midnight.used {
        $ternary := RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
                infix => RakuAST::Infix.new('=='),
                right => RakuAST::IntLiteral.new(0)
            ),
            then => RakuAST::StrLiteral.new(terms.midnight),
            else => $ternary
        )
    }


    return
    RakuAST::Statement::Expression.new(expression =>
        RakuAST::ApplyInfix.new(
            left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('minute')),
                    operand => Source,
                ),
                infix => RakuAST::Infix.new('+'),
                right => RakuAST::ApplyInfix.new(
                    left => RakuAST::IntLiteral.new(60),
                    infix => RakuAST::Infix.new('*'),
                    right => RakuAST::ApplyPostfix.new(
                        postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('hour')),
                        operand => Source
                    )
                )
            )
        )
    ),
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(
            left => Result,
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => Result,
                infix => Concat,
                right => $ternary
            )
        )
    )

}