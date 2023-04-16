use v6.d;
unit module G-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'G' formatter is the era formatter. (BC/AD)
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
sub format-G(\width,\data) is export {
    constant is-AD = RakuAST::ApplyInfix.new(
        left => RakuAST::ApplyPostfix.new(
            postfix => RakuAST::Call::Method.new(
                name => RakuAST::Name.from-identifier('year')
            ),
            operand => Source,
        ),
        infix => RakuAST::Infix.new('>'),
        right => RakuAST::IntLiteral.new(0)
    );

    # Currently isn't working with English
    my \terms = width > 4
        ?? data.calendar.eras.narrow
        !! width == 4
            ?? data.calendar.eras.wide
            !! data.calendar.eras.abbreviated;

    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(
            left => Result,
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => Result,
                infix => Concat,
                right => RakuAST::Ternary.new(
                    condition => is-AD,
                    then => RakuAST::StrLiteral.new(terms[0]),
                    else => RakuAST::StrLiteral.new(terms[1])
                )
            )
        )
    )
}