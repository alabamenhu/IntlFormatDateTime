use v6.d;
unit module A-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'A' formatter is the milliseconds formatter.
# The number of letters indicates the 0-padding (if any) that should be done.


constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');
constant Add    = RakuAST::Infix.new('+');
constant Times  = RakuAST::Infix.new('*');
constant GetSecond  = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('second'));
constant GetMinute  = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('minute'));
constant GetHour    = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('hour'));
constant Floor      = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('floor'));
constant Stringify  = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

sub format-A(\digits, \data) is export {
    # $temp = ($datetime.second * 1_000_000).floor + ($datetime.hour * 3600_000_000) + ($datetime.minute * 60_000_000);
    # $temp = transliterate( ('0' x ($temp.chars - digits)) ~ $temp);
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(:infix(Assign),
            left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
            right => RakuAST::ApplyInfix.new( infix => Add,
                left => RakuAST::ApplyInfix.new( infix => Times,
                    left => RakuAST::IntLiteral.new(3600_000_000),
                    right => RakuAST::ApplyPostfix.new(
                        operand => Source,
                        postfix => GetHour
                    )
                ),
                right => RakuAST::ApplyInfix.new( infix => Add,
                    left => RakuAST::ApplyInfix.new( infix => Times,
                        left => RakuAST::IntLiteral.new(60_000_000),
                        right => RakuAST::ApplyPostfix.new(
                            operand => Source,
                            postfix => GetMinute,
                            )
                        ),
                    right => RakuAST::ApplyPostfix.new(
                        postfix => Floor,
                        operand => RakuAST::ApplyInfix.new( infix => Times,
                            left => RakuAST::IntLiteral.new(1_000_000),
                            right => RakuAST::ApplyPostfix.new(
                                postfix => GetSecond,
                                operand => Source
                            )
                        )
                    )
                )
            )
        )
    ),
    concat-to-result-stmt( intl-digit-wrap(data.number-system,
        RakuAST::ApplyInfix.new(
            left => RakuAST::ApplyInfix.new(
                left => RakuAST::StrLiteral.new('0'),
                infix => RakuAST::Infix.new('x'),
                right => RakuAST::ApplyInfix.new(
                    left => RakuAST::IntLiteral.new(digits),
                    infix => RakuAST::Infix.new('-'),
                    right => RakuAST::ApplyPostfix.new(
                        operand => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
                        postfix => RakuAST::Call::Method.new( name => RakuAST::Name.from-identifier('chars'))
                    )
                )
            ),
            infix => Concat,
            right => RakuAST::Var::Lexical.new('$DATETIMETEMP1')
        )
    ))
}