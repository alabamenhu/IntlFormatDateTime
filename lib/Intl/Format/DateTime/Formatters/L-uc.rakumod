use v6.d;
unit module L-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'L' formatter is the months formatter
#
# 'L' and 'LL' format numerically (without or with 0-padding)
# 'LLL' through 'LLLLL' use stand-alone textual forms.

constant Source    = RakuAST::Var::Lexical.new('$datetime');
constant Assign    = RakuAST::Infix.new(':=');
constant Concat    = RakuAST::Infix.new('~');
constant Mod       = RakuAST::Infix.new('%');
constant Lesser    = RakuAST::Infix.new('<');
constant GetMonth  = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('month'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-L($,$) is export { * }
multi sub format-L(1,\data) {
    concat-to-result-stmt intl-digit-wrap( data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => RakuAST::ApplyPostfix.new(
                postfix => GetMonth,
                operand => Source
            ),
        ),
    )
}
multi sub format-L(2,\data) {
    concat-to-result-stmt intl-digit-wrap( data.number-system,
        RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    postfix => GetMonth,
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
                        postfix => GetMonth,
                        operand => Source
                    ),
                ),
            ),
            else => RakuAST::ApplyPostfix.new(
                postfix => Stringify,
                operand => RakuAST::ApplyPostfix.new(
                    postfix => GetMonth,
                    operand => Source
                ),
            ),
        )
    )
}

multi sub format-L(\width,\data) {
    my \terms = width > 4
        ?? data.calendar.months.stand-alone.narrow           # 5+
        !! width == 4
            ?? data.calendar.months.stand-alone.wide         # 4
            !! data.calendar.months.stand-alone.abbreviated; # 3

    return
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::VarDeclaration::Constant.new(
            name => ('DATETIMEFMT-L' ~ width),
            scope    => 'my',
            initializer => RakuAST::Initializer::Assign.new(
                RakuAST::ApplyListInfix.new(
                    infix    => RakuAST::Infix.new(","),
                    operands => (
                        RakuAST::StrLiteral.new(''),
                        RakuAST::StrLiteral.new(terms[1]),
                        RakuAST::StrLiteral.new(terms[2]),
                        RakuAST::StrLiteral.new(terms[3]),
                        RakuAST::StrLiteral.new(terms[4]),
                        RakuAST::StrLiteral.new(terms[5]),
                        RakuAST::StrLiteral.new(terms[6]),
                        RakuAST::StrLiteral.new(terms[7]),
                        RakuAST::StrLiteral.new(terms[8]),
                        RakuAST::StrLiteral.new(terms[9]),
                        RakuAST::StrLiteral.new(terms[10]),
                        RakuAST::StrLiteral.new(terms[11]),
                        RakuAST::StrLiteral.new(terms[12]),
                    )
                )
            )
        )
    ),
    concat-to-result-stmt RakuAST::ApplyPostfix.new(
        operand => RakuAST::Var::Lexical::Constant.new('DATETIMEFMT-L' ~ width),
        postfix => RakuAST::Postcircumfix::ArrayIndex.new(
            index => RakuAST::SemiList.new(
                RakuAST::ApplyPostfix.new(
                    postfix => GetMonth,
                    operand => Source
                ),
            )
        )
    )
}