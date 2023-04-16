use v6.d;
unit module x-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'x' formatter is the ISO timezone formatter
#
# For 'x':     zero-padded hours obligatory, minutes optional only if not 0
# For 'xx':    zero-padded hours obligatory, minutes obligatory
# For 'xxx':   zero-padded hours obligatory, minutes obligatory, colon-separated
# For 'xxxx':  zero-padded hours obligatory, minutes obligatory, seconds optional
# For 'xxxxx': zero-padded hours obligatory, minutes obligatory, seconds optional, colon separated
#
# This isn't optimized because I'm lazy.
constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Temp   = RakuAST::Var::Lexical.new('$DATETIMETEMP1');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');
constant Plus   = RakuAST::Infix.new('+');
constant IntMod      = RakuAST::Infix.new('%');
constant GetTZ       = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('offset'));
constant GetTZHour   = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('offset-in-hours'));
constant GetTZMinute = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('offset-in-minutes'));
constant GetAbs      = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('abs'));
constant GetFloor    = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('floor'));
constant Stringify   = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-x ($, $) is export { * }

multi sub format-x(1,\data) {
    |concat-hour,
    |concat-minute(:optional),
}

multi sub format-x(2,\data) {
    |concat-hour,
    |concat-minute,
}
multi sub format-x(3,\data) {
    |concat-hour,
    |concat-minute(:colon),
}
multi sub format-x(4,\data) {
    |concat-hour,
    |concat-minute,
    |concat-second,
}
multi sub format-x(5,\data) {
    |concat-hour,
    |concat-minute(:colon),
    |concat-second(:colon),
}

sub concat-hour {
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::ApplyPostfix.new(
                operand => RakuAST::ApplyPostfix.new(
                    operand => Source,
                    postfix => GetTZHour,
                ),
                postfix => GetFloor,
            )
        )
    ),
    concat-to-result-stmt(
        RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => Temp,
                infix => RakuAST::Infix.new('<'),
                right => RakuAST::IntLiteral.new(0)
            ),
            then => RakuAST::StrLiteral.new('-'),
            else => RakuAST::StrLiteral.new('+'),
        )
    ),
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::ApplyPostfix.new(
                    operand => Temp,
                    postfix => GetAbs,
            )
        )
    ),
    concat-to-result-stmt(
        RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => Temp,
                infix => RakuAST::Infix.new('>'),
                right => RakuAST::IntLiteral.new(9)
            ),
            then => RakuAST::ApplyPostfix.new(
                postfix => Stringify,
                operand => Temp,
            ),
            else => RakuAST::ApplyInfix.new(
                left => RakuAST::StrLiteral.new('0'),
                infix => Concat,
                right => RakuAST::ApplyPostfix.new(
                    postfix => Stringify,
                    operand => Temp,
                ),
            )
        )
    )
}

sub concat-minute(:$colon = False, :$optional = False) {
    my %condition;
    %condition<condition-modifier> = RakuAST::StatementModifier::If.new(
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => RakuAST::Infix.new('>'),
            right => RakuAST::IntLiteral.new(0),
        )
    ) if $optional;
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    operand => RakuAST::ApplyPostfix.new(
                        operand => RakuAST::ApplyPostfix.new(
                            operand => Source,
                            postfix => GetTZMinute,
                        ),
                        postfix => GetAbs,
                    ),
                    postfix => GetFloor
                ),
                infix => IntMod,
                right => RakuAST::IntLiteral.new(60),
            )
        )
    ),
    RakuAST::Statement::Expression.new(
        expression => RakuAST::ApplyInfix.new(
            left  => Result,
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => Result,
                infix => Concat,
                right => ($colon
                    ?? RakuAST::ApplyInfix.new(
                        left => RakuAST::StrLiteral.new(':'),
                        infix => Concat,
                        right => RakuAST::Ternary.new(
                            condition => RakuAST::ApplyInfix.new(
                                left => Temp,
                                infix => RakuAST::Infix.new('>'),
                                right => RakuAST::IntLiteral.new(9)
                            ),
                            then => RakuAST::ApplyPostfix.new(
                                postfix => Stringify,
                                operand => Temp,
                            ),
                            else => RakuAST::ApplyInfix.new(
                                left => RakuAST::StrLiteral.new('0'),
                                infix => Concat,
                                right => RakuAST::ApplyPostfix.new(
                                    postfix => Stringify,
                                    operand => Temp,
                                ),
                            )
                        )
                    )
                    !! RakuAST::Ternary.new(
                        condition => RakuAST::ApplyInfix.new(
                            left => Temp,
                            infix => RakuAST::Infix.new('>'),
                            right => RakuAST::IntLiteral.new(9)
                        ),
                        then => RakuAST::ApplyPostfix.new(
                            postfix => Stringify,
                            operand => Temp,
                        ),
                        else => RakuAST::ApplyInfix.new(
                            left => RakuAST::StrLiteral.new('0'),
                            infix => Concat,
                            right => RakuAST::ApplyPostfix.new(
                                postfix => Stringify,
                                operand => Temp,
                            ),
                        )
                    )
                )
            )
        ),
        |%condition
    );
}

# This is always optional
sub concat-second(:$colon = False) {
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    operand => RakuAST::ApplyPostfix.new(
                        operand => RakuAST::ApplyPostfix.new(
                            operand => Source,
                            postfix => GetTZMinute,
                        ),
                        postfix => GetAbs,
                    ),
                    postfix => GetFloor
                ),
                infix => IntMod,
                right => RakuAST::IntLiteral.new(60),
            )
        )
    ),
    RakuAST::Statement::Expression.new(
        expression => RakuAST::ApplyInfix.new(
            left  => Result,
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => Result,
                infix => Concat,
                right => ($colon
                    ?? RakuAST::ApplyInfix.new(
                        left => RakuAST::StrLiteral.new(':'),
                        infix => Concat,
                        right => RakuAST::Ternary.new(
                            condition => RakuAST::ApplyInfix.new(
                                left => Temp,
                                infix => RakuAST::Infix.new('>'),
                                right => RakuAST::IntLiteral.new(9)
                            ),
                            then => RakuAST::ApplyPostfix.new(
                                postfix => Stringify,
                                operand => Temp,
                            ),
                            else => RakuAST::ApplyInfix.new(
                                left => RakuAST::StrLiteral.new('0'),
                                infix => Concat,
                                right => RakuAST::ApplyPostfix.new(
                                    postfix => Stringify,
                                    operand => Temp,
                                ),
                            )
                        )
                    )
                    !! RakuAST::Ternary.new(
                        condition => RakuAST::ApplyInfix.new(
                            left => Temp,
                            infix => RakuAST::Infix.new('>'),
                            right => RakuAST::IntLiteral.new(9)
                        ),
                        then => RakuAST::ApplyPostfix.new(
                            postfix => Stringify,
                            operand => Temp,
                        ),
                        else => RakuAST::ApplyInfix.new(
                            left => RakuAST::StrLiteral.new('0'),
                            infix => Concat,
                            right => RakuAST::ApplyPostfix.new(
                                postfix => Stringify,
                                operand => Temp,
                            ),
                        )
                    )
                )
            )
        ),
        condition-modifier => RakuAST::StatementModifier::If.new(
            RakuAST::ApplyInfix.new(
                left => Temp,
                infix => RakuAST::Infix.new('>'),
                right => RakuAST::IntLiteral.new(0),
            )
        )
    );
}