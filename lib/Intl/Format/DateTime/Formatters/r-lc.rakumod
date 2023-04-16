use v6.d;
unit module r-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'r' formatter is the numeric Gregorian year formatter.
# The number of 'r' strictly indicates padding -- there is no two-digit version.
#
# TODO: when alternate calendars are enabled, ensure that this pulls the GREGORIAN year from month 1, day 1.
#
# Numbers are NOT localized (e.g. always use <0…9> and not <۰…۹>
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Temp   = RakuAST::Var::Lexical.new('$DATETIMETEMP1');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');
constant Repeat = RakuAST::Infix.new('x');
constant GetYear   = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('year'));
constant Chars     = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('chars'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

sub format-r(\padding,\data) is export {
    # $temp = $datetime.year.Str;
    # $result = '0' x (padding - $temp.chars) ~ $temp);
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(:infix(Assign),
            left => Temp,
            right => RakuAST::ApplyPostfix.new(
                postfix => Stringify,
                operand => RakuAST::ApplyPostfix.new(
                    postfix => GetYear,
                    operand => Source,
                )
            )
        )
    ),
    concat-to-result-stmt RakuAST::ApplyInfix.new(
        left => RakuAST::ApplyInfix.new(
            left => RakuAST::StrLiteral.new('0'),
            infix => Repeat,
            right => RakuAST::ApplyInfix.new(
                left => RakuAST::IntLiteral.new(padding),
                infix => RakuAST::Infix.new('-'),
                right => RakuAST::ApplyPostfix.new(
                    operand => Temp,
                    postfix => Chars
                )
            )
        ),
        infix => Concat,
        right => Temp
    )

}
