use v6.d;
unit module D-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'D' formatter is the days-in-year formatter.
# The number of letters indicates the 0-padding (if any) that should be done.
# Per the standard, the maximum is DDD.  The single 'D' will be used if more are used.

constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');
constant Add    = RakuAST::Infix.new('+');
constant Times  = RakuAST::Infix.new('*');
constant GetDay    = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('day-of-year'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-D($,$) is export { * }
multi sub format-D($, \data)  {
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
multi sub format-D(2, \data) {
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    operand => Source,
                    postfix => GetDay
                ),
                infix => RakuAST::Infix.new('<'),
                right => RakuAST::IntLiteral.new(10),
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

multi sub format-D(3, \data) {
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new( infix => Assign,
            left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
            right => RakuAST::ApplyPostfix.new(
                    operand => Source,
                    postfix => GetDay
            )
        )
    ),
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
                infix => RakuAST::Infix.new('>'),
                right => RakuAST::IntLiteral.new(100),
            ),
            then => RakuAST::ApplyPostfix.new(
                operand => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
                postfix => Stringify
            ),
            else => RakuAST::Ternary.new(
                condition => RakuAST::ApplyInfix.new(
                    left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
                    infix => RakuAST::Infix.new('>'),
                    right => RakuAST::IntLiteral.new(10)
                ),
                then => RakuAST::ApplyInfix.new(
                    left => RakuAST::StrLiteral.new('0'),
                    infix => Concat,
                    right => RakuAST::ApplyPostfix.new(
                        operand => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
                        postfix => Stringify
                    )
                ),
                else => RakuAST::ApplyInfix.new(
                    left => RakuAST::StrLiteral.new('00'),
                    infix => Concat,
                    right => RakuAST::ApplyPostfix.new(
                        operand => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
                        postfix => Stringify
                    )
                )
            )
        )
    )
}