use v6.d;
unit module E-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'E' formatter is the day-of-week formatter in text forms
#
# 'E', 'EE', and 'EEE' are identical.
# 'EEEE', 'EEEEE', and 'EEEEEE'  give various lengths of
# the day of the week in textual form (format version)

constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');

sub format-E(\width,\data) is export {
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