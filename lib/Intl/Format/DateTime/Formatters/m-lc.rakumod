use v6.d;
unit module m-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;

# The 'm' formatter is the minute formatter.
# 'mm' is padded as needed with a single zero.

constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');
constant Add    = RakuAST::Infix.new('+');
constant Times  = RakuAST::Infix.new('*');
constant GetMinute = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('minute'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-m($,$) is export { * }
multi sub format-m($, \data)  {
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => RakuAST::ApplyPostfix.new(
                operand => Source,
                postfix => GetMinute
            )
        )
    )
}
multi sub format-m(2, \data) {
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    operand => Source,
                    postfix => GetMinute
                ),
                infix => RakuAST::Infix.new('>'),
                right => RakuAST::IntLiteral.new(9),
            ),
            then => RakuAST::ApplyPostfix.new(
                operand => RakuAST::ApplyPostfix.new(
                    operand => Source,
                    postfix => GetMinute
                ),
                postfix => Stringify
            ),
            else => RakuAST::ApplyInfix.new(
                left => RakuAST::StrLiteral.new('0'),
                infix => Concat,
                right => RakuAST::ApplyPostfix.new(
                    operand => RakuAST::ApplyPostfix.new(
                        operand => Source,
                        postfix => GetMinute
                    ),
                    postfix => Stringify
                )
            )
        )
    )
}