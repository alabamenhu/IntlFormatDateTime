use v6.d;
unit module K-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'K' formatter is the 0-11 hours formatter
#
# The only distinction is that 'KK' pads with one zero.
# More are treated as identical to a single one.

constant Source    = RakuAST::Var::Lexical.new('$datetime');
constant Temp      = RakuAST::Var::Lexical.new('$DATETIMETEMP1');
constant Assign    = RakuAST::Infix.new(':=');
constant Concat    = RakuAST::Infix.new('~');
constant Mod       = RakuAST::Infix.new('%');
constant Lesser    = RakuAST::Infix.new('<');
constant GetHour   = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('hour'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-K($,$) is export { * }
multi sub format-K($,\data) {
    RakuAST::Statement::Expression.new(expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    postfix => GetHour,
                    operand => Source
                ),
                infix => Mod,
                right => RakuAST::IntLiteral.new(12)
            )
        ),
    ),
    concat-to-result-stmt intl-digit-wrap( data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => Temp
        ),
    )
}
multi sub format-K(2,\data) {
    RakuAST::Statement::Expression.new(expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    postfix => GetHour,
                    operand => Source
                ),
                infix => Mod,
                right => RakuAST::IntLiteral.new(12)
            )
        ),
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