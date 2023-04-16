use v6.d;
unit module s-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;

# The 's' formatter is the second formatter.
# 'ss' is padded as needed with a single zero.

constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');
constant Add    = RakuAST::Infix.new('+');
constant Times  = RakuAST::Infix.new('*');
constant GetSecond = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('second'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-s($,$) is export { * }
multi sub format-s($, \data)  {
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => RakuAST::ApplyPostfix.new(
                operand => Source,
                postfix => GetSecond
            )
        )
    )
}
multi sub format-s(2, \data) {
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    operand => Source,
                    postfix => GetSecond
                ),
                infix => RakuAST::Infix.new('>'),
                right => RakuAST::IntLiteral.new(9),
            ),
            then => RakuAST::ApplyPostfix.new(
                operand => RakuAST::ApplyPostfix.new(
                    operand => Source,
                    postfix => GetSecond
                ),
                postfix => Stringify
            ),
            else => RakuAST::ApplyInfix.new(
                left => RakuAST::StrLiteral.new('0'),
                infix => Concat,
                right => RakuAST::ApplyPostfix.new(
                    operand => RakuAST::ApplyPostfix.new(
                        operand => Source,
                        postfix => GetSecond
                    ),
                    postfix => Stringify
                )
            )
        )
    )
}