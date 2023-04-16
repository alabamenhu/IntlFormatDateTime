use v6.d;
unit module H-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'H' formatter is the 0-23 hours formatter
#
# The only distinction is that 'HH' pads with one zero.
# More are treated as identical to a single one.

constant Source    = RakuAST::Var::Lexical.new('$datetime');
constant Temp      = RakuAST::Var::Lexical.new('$DATETIMETEMP1');
constant Assign    = RakuAST::Infix.new(':=');
constant Concat    = RakuAST::Infix.new('~');
constant Mod       = RakuAST::Infix.new('%');
constant Lesser    = RakuAST::Infix.new('<');
constant GetHour   = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('hour'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-H($,$) is export { * }
multi sub format-H($,\data) {
    concat-to-result-stmt intl-digit-wrap( data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => RakuAST::ApplyPostfix.new(
                postfix => GetHour,
                operand => Source
            ),
        ),
    )
}
multi sub format-H(2,\data) {
    concat-to-result-stmt intl-digit-wrap( data.number-system,
        RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    postfix => GetHour,
                    operand => Source
                ),
                infix => Lesser,
                right => RakuAST::IntLiteral.new(10),
            ),
            then => RakuAST::ApplyInfix.new(
                left => RakuAST::StrLiteral.new('0'),
                infix => Concat,
                right => RakuAST::ApplyPostfix.new(
                    postfix => Stringify,
                    operand => RakuAST::ApplyPostfix.new(
                        postfix => GetHour,
                        operand => Source
                    ),
                ),
            ),
            else => RakuAST::ApplyPostfix.new(
                postfix => Stringify,
                operand => RakuAST::ApplyPostfix.new(
                    postfix => GetHour,
                    operand => Source
                ),
            ),
        )
    )
}