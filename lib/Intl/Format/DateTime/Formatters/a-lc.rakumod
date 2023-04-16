use v6.d;
unit module a-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'a' formatter is the ᴀᴍ/ᴘᴍ formatter
#
# 'a', 'aa', and 'aaa' are identical, so specific versions are provided for
# 4 and 5, and then 1-3 is placed in a catch all

constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');

# $result = $result ~ ($datetime.hour < 12
#   ?? day-periods.format.abbreviated.am
#   !! day-periods.format.abbreviated.pm
sub format-a(\width,\data) is export {
    constant before-noon = RakuAST::ApplyInfix.new(
        left => RakuAST::ApplyPostfix.new(
            postfix => RakuAST::Call::Method.new(
                name => RakuAST::Name.from-identifier('hour')
            ),
            operand => Source,
        ),
        infix => RakuAST::Infix.new('<'),
        right => RakuAST::IntLiteral.new(12)
    );

    my \terms = width > 4
        ?? data.calendar.day-periods.format.narrow
        !! width == 4
            ?? data.calendar.day-periods.format.wide
            !! data.calendar.day-periods.format.abbreviated;

    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(
            left => Result,
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => Result,
                infix => Concat,
                right => RakuAST::Ternary.new(
                    condition => before-noon,
                    then => RakuAST::StrLiteral.new(terms.am),
                    else => RakuAST::StrLiteral.new(terms.pm)
                )
            )
        )
    )
}