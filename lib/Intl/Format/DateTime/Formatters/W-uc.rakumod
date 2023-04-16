use v6.d;
unit module W-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;

# The 'W' formatter is the week of month formatter.  It's not commonly used.
# There is only a single width per CLDR as it can only be 1-5.

constant Result    = RakuAST::Var::Lexical.new('$result');
constant Source    = RakuAST::Var::Lexical.new('$datetime');
constant Assign    = RakuAST::Infix.new(':=');
constant Concat    = RakuAST::Infix.new('~');
constant Add       = RakuAST::Infix.new('+');
constant Minus     = RakuAST::Infix.new('-');
constant IntDivide = RakuAST::Infix.new('div');
constant GetDay    = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('day'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

# (($day - $first-day-in-week) div 7) + 2
sub format-W($, \data) is export {
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => RakuAST::ApplyInfix.new(
                left => RakuAST::IntLiteral.new(2),
                infix => Add,
                right => RakuAST::Applyinfix.new(
                    right => RakuAST::IntLiteral.new(7),
                    infix => RakuAST::IntDivide,
                    left => RakuAST::ApplyInfix.new(
                        left => RakuAST::ApplyPostfix.new(
                            operand => Source,
                            postfix => GetDay
                        ),
                        infix => Minus,
                        right => RakuAST::IntLiteral.new(data.first-day-in-week)
                    )
                )
            )
        )
    )
}
