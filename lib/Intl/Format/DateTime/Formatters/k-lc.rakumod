use v6.d;
unit module k-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'k' formatter is the 1-24 hours formatter
#
# The only distinction is that 'kk' pads with one zero.
# More are treated as identical to a single one.
# This is identical to H, but upshifted by 1.  Used in a handful of locales.

constant Source    = RakuAST::Var::Lexical.new('$datetime');
constant Temp      = RakuAST::Var::Lexical.new('$DATETIMETEMP1');
constant Assign    = RakuAST::Infix.new(':=');
constant Concat    = RakuAST::Infix.new('~');
constant Mod       = RakuAST::Infix.new('%');
constant Lesser    = RakuAST::Infix.new('<');
constant Plus      = RakuAST::Infix.new('+');
constant GetHour   = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('hour'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-k($,$) is export { * }
multi sub format-k($,\data) {
    concat-to-result-stmt intl-digit-wrap( data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => RakuAST::ApplyInfix.new(
                left => RakuAST::IntLiteral.new(1),
                infix => Plus,
                right => RakuAST::ApplyPostfix.new(
                    postfix => GetHour,
                    operand => Source
                )
            ),
        ),
    )
}
multi sub format-k(2,\data) {
    RakuAST::Statement::Expression.new(expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => RakuAST::IntLiteral.new(1),
                infix => Plus,
                right => RakuAST::ApplyPostfix.new(
                    postfix => GetHour,
                    operand => Source
                )
            )
        )
    ),
    concat-to-result-stmt intl-digit-wrap( data.number-system,
        RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => Temp,
                infix => Lesser,
                right => RakuAST::IntLiteral.new(10),
            ),
            then => RakuAST::ApplyInfix.new(
                left => RakuAST::StrLiteral.new('0'),
                infix => Concat,
                right => RakuAST::ApplyPostfix.new(
                    postfix => Stringify,
                    operand => Temp,
                ),
            ),
            else => RakuAST::ApplyPostfix.new(
                postfix => Stringify,
                operand => Temp,
            ),
        )
    )
}