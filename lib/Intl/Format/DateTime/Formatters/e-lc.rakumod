use v6.d;
unit module e-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'e' formatter is the day-of-week formatter
#
# 'e' and 'ee' provide a simple number (0 padded for 'ee').
# 'eee' through 'eeee' give various lengths of the day of the
# week in textual form (format version)

constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');

proto sub format-e($,$) is export { * }
multi sub format-e(1,\data) {
    # day-of-week-adjustment needed here
    # $result ~= (($datetime.day-of-week) + $adjust) % 7 + 1;
    my $day-of-week-adjustment = (0,6,5,4,3,2,1)[data.first-day-in-week];
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str')),
            operand => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyInfix.new(
                    left => ($day-of-week-adjustment
                        ?? RakuAST::ApplyInfix.new(
                            right => RakuAST::ApplyPostfix.new(
                                postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('day-of-week')),
                                operand => Source
                            ),
                            infix => RakuAST::Infix.new('+'),
                            left => RakuAST::IntLiteral.new($day-of-week-adjustment)
                        )
                        !! RakuAST::ApplyPostfix.new(
                            postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('day-of-week')),
                            operand => Source
                        )
                    ),
                    infix => RakuAST::Infix.new('%'),
                    right => RakuAST::IntLiteral.new(7)
                ),
                infix => RakuAST::Infix.new('+'),
                right => RakuAST::IntLiteral.new(1),
            )
        )
    )
}

multi sub format-e(2,\data) {
    # Identical to 'c', except it is 0 padded for some reason
    # day-of-week-adjustment needed here
    # $result ~= (($datetime.day-of-week) + $adjust) % 7 + 1;
    my $day-of-week-adjustment = (0,6,5,4,3,2,1)[data.first-day-in-week];
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::ApplyInfix.new(
            left => RakuAST::StrLiteral.new('0'),
            infix => Concat,
            right => RakuAST::ApplyPostfix.new(
                postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str')),
                operand => RakuAST::ApplyInfix.new(
                    left => RakuAST::ApplyInfix.new(
                        left => ($day-of-week-adjustment
                            ?? RakuAST::ApplyInfix.new(
                                right => RakuAST::ApplyPostfix.new(
                                    postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('day-of-week')),
                                    operand => Source
                                ),
                                infix => RakuAST::Infix.new('+'),
                                left => RakuAST::IntLiteral.new($day-of-week-adjustment)
                            )
                            !! RakuAST::ApplyPostfix.new(
                                postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('day-of-week')),
                                operand => Source
                            )
                        ),
                        infix => RakuAST::Infix.new('%'),
                        right => RakuAST::IntLiteral.new(7)
                    ),
                    infix => RakuAST::Infix.new('+'),
                    right => RakuAST::IntLiteral.new(1),
                )
            )
        )
    )
}

multi sub format-e(\width,\data) {
    my \terms = width > 4
        ?? width == 6
            ?? data.calendar.days.format.narrow         # 6 -- TODO: should be .short but not currently available in CLDR
            !! data.calendar.days.format.narrow         # 5
        !! width == 4
            ?? data.calendar.days.format.wide           # 4
            !! data.calendar.days.format.abbreviated;   # 3

    return
    concat-to-result-stmt RakuAST::ApplyPostfix.new(
        operand => RakuAST::ApplyListInfix.new(
            infix    => RakuAST::Infix.new(","),
            operands => (
                RakuAST::StrLiteral.new(''),
                RakuAST::StrLiteral.new(terms.mon),
                RakuAST::StrLiteral.new(terms.tue),
                RakuAST::StrLiteral.new(terms.wed),
                RakuAST::StrLiteral.new(terms.thu),
                RakuAST::StrLiteral.new(terms.fri),
                RakuAST::StrLiteral.new(terms.sat),
                RakuAST::StrLiteral.new(terms.sun),
            )
        ),
        postfix => RakuAST::Postcircumfix::ArrayIndex.new(
            index => RakuAST::SemiList.new(
                RakuAST::ApplyPostfix.new(
                    postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('day-of-week')),
                    operand => Source
                ),
            )
        )
    )
}