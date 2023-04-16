use v6.d;
unit module q-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'q' formatter is the quarter formatter
#
# 'q' and 'q' provide a simple number (0 padded for 'qq').
# 'QQQ' through 'QQQQ' give various quarters of the year
# in textual form (formatted)

constant Result    = RakuAST::Var::Lexical.new('$result');
constant Source    = RakuAST::Var::Lexical.new('$datetime');
constant Assign    = RakuAST::Infix.new(':=');
constant Concat    = RakuAST::Infix.new('~');
constant Minus     = RakuAST::Infix.new('-');
constant Plus      = RakuAST::Infix.new('+');
constant IntDivide = RakuAST::Infix.new('div');
constant GetMonth  = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('month'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-q($,$) is export { * }
multi sub format-q(1,\data) {
    concat-to-result-stmt intl-digit-wrap( data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyInfix.new(
                    left => RakuAST::ApplyPostfix.new(
                        postfix => GetMonth,
                        operand => Source
                    ),
                    infix => Plus,
                    right => RakuAST::IntLiteral.new(2),
                ),
                infix => IntDivide,
                right => RakuAST::IntLiteral.new(3)
            ),
        ),
    )
}

multi sub format-q(2,\data) {
    # Padding is guaranteed here, so no conditional needed
    concat-to-result-stmt intl-digit-wrap( data.number-system,
        RakuAST::ApplyInfix.new(
            left => RakuAST::StrLiteral.new('0'),
            infix => Concat,
            right => RakuAST::ApplyPostfix.new(
                postfix => Stringify,
                operand => RakuAST::ApplyInfix.new(
                    left => RakuAST::ApplyInfix.new(
                        left => RakuAST::ApplyPostfix.new(
                            postfix => GetMonth,
                            operand => Source
                        ),
                        infix => Plus,
                        right => RakuAST::IntLiteral.new(2),
                    ),
                    infix => IntDivide,
                    right => RakuAST::IntLiteral.new(3)
                ),
            )
        )
    )
}

multi sub format-q(\width,\data) {
    my \terms = width > 4
        ?? data.calendar.quarters.format.narrow             # 5
        !! width == 4
            ?? data.calendar.quarters.format.wide           # 4
            !! data.calendar.quarters.format.abbreviated;   # 3

    return
        RakuAST::Statement::Expression.new( expression =>
        RakuAST::VarDeclaration::Constant.new(
            name => ('DATETIMEFMT-q' ~ width),
            scope    => 'my',
            initializer => RakuAST::Initializer::Assign.new(
                RakuAST::ApplyListInfix.new(
                    infix    => RakuAST::Infix.new(","),
                    operands => (
                        RakuAST::StrLiteral.new(terms[1]),
                        RakuAST::StrLiteral.new(terms[2]),
                        RakuAST::StrLiteral.new(terms[3]),
                        RakuAST::StrLiteral.new(terms[4]),
                    )
                )
            )
        )
    ),
    concat-to-result-stmt RakuAST::ApplyPostfix.new(
        operand => RakuAST::Var::Lexical::Constant.new('DATETIMEFMT-q' ~ width),
        postfix => RakuAST::Postcircumfix::ArrayIndex.new(
            index => RakuAST::SemiList.new(
                RakuAST::ApplyInfix.new(
                    left => RakuAST::ApplyInfix.new(
                        left => RakuAST::ApplyPostfix.new(
                            postfix => GetMonth,
                            operand => Source
                        ),
                        infix => Minus,
                        right => RakuAST::IntLiteral.new(1),
                    ),
                    infix => IntDivide,
                    right => RakuAST::IntLiteral.new(3)
                ),
            )
        )
    )
}