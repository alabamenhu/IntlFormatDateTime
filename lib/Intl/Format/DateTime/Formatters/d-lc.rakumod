use v6.d;
unit module d-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'd' formatter is the day (of month) formatter.
# 'dd' is padded as needed with a single zero.


constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');
constant Add    = RakuAST::Infix.new('+');
constant Times  = RakuAST::Infix.new('*');
constant GetDay    = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('day'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-d($,$) is export { * }
multi sub format-d(1, \data)  {
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => RakuAST::ApplyPostfix.new(
                operand => Source,
                postfix => GetDay
            )
        )
    )
}
multi sub format-d(2, \data) {
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    operand => Source,
                    postfix => GetDay
                ),
                infix => RakuAST::Infix.new('>'),
                right => RakuAST::IntLiteral.new(9),
            ),
            then => RakuAST::ApplyPostfix.new(
                operand => RakuAST::ApplyPostfix.new(
                    operand => Source,
                    postfix => GetDay
                ),
                postfix => Stringify
            ),
            else => RakuAST::ApplyInfix.new(
                left => RakuAST::StrLiteral.new('0'),
                infix => Concat,
                right => RakuAST::ApplyPostfix.new(
                    operand => RakuAST::ApplyPostfix.new(
                        operand => Source,
                        postfix => GetDay
                    ),
                    postfix => Stringify
                )
            )
        )
    )
}