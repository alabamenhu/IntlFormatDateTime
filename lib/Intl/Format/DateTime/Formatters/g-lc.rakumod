use v6.d;
unit module g-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'A' formatter is the milliseconds formatter.
# The number of letters indicates the 0-padding (if any) that should be done.


constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Temp   = RakuAST::Var::Lexical.new('$DATETIMETEMP1');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');
constant Minus  = RakuAST::Infix.new('-');
constant Repeat = RakuAST::Infix.new('x');
constant GetDays    = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('daycount'));
constant Stringify  = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));
constant CountChars = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('chars'));

sub format-g(\digits, \data) is export {
    # $temp = ($datetime.second * 1_000_000).floor + ($datetime.hour * 3600_000_000) + ($datetime.minute * 60_000_000);
    # $temp = transliterate( ('0' x ($temp.chars - digits)) ~ $temp);
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(
            infix => Assign,
            left => Temp,
            right => RakuAST::ApplyPostfix.new(
                postfix => Stringify,
                operand => RakuAST::ApplyPostfix.new(
                    operand => Source,
                    postfix => GetDays
                )
            )
        )
    ),
    concat-to-result-stmt( intl-digit-wrap(data.number-system,
        RakuAST::ApplyInfix.new(
            left => RakuAST::ApplyInfix.new(
                left => RakuAST::StrLiteral.new('0'),
                infix => Repeat,
                right => RakuAST::ApplyInfix.new(
                    left => RakuAST::IntLiteral.new(digits),
                    infix => Minus,
                    right => RakuAST::ApplyPostfix.new(
                        operand => Temp,
                        postfix => CountChars
                    )
                )
            ),
            infix => Concat,
            right => Temp
        )
    ))
}