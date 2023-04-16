use v6.d;
unit module h-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'h' formatter is the 1-12 hours formatter
#
# The only distinction is that 'hh' pads with one zero.
# More are treated as identical to a single one.

constant Source    = RakuAST::Var::Lexical.new('$datetime');
constant Temp      = RakuAST::Var::Lexical.new('$DATETIMETEMP1');
constant Assign    = RakuAST::Infix.new(':=');
constant Concat    = RakuAST::Infix.new('~');
constant Mod       = RakuAST::Infix.new('%');
constant Lesser    = RakuAST::Infix.new('<');
constant GetHour   = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('hour'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-h($,$) is export { * }
multi sub format-h($,\data) {
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
    RakuAST::Statement::Expression.new(expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::IntLiteral.new(12)
        ),
        condition-modifier => RakuAST::StatementModifier::Unless.new(
            Temp
        )
    ),
    concat-to-result-stmt intl-digit-wrap( data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => Temp
        ),
    )
}
multi sub format-h(2,\data) {
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
    RakuAST::Statement::Expression.new(expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::IntLiteral.new(12)
        ),
        condition-modifier => RakuAST::StatementModifier::Unless.new(
            Temp
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