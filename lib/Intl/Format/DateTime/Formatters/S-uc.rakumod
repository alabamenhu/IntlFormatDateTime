use v6.d;
unit module S-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'S' formatter is the fractional seconds formatter
#
# All of the formatting codes are interpreted as 'provide
# fractional seconds to this many units of precision'.
constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');
constant GetSecond = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('second'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

sub format-S(\digits, \data) is export {
    # $temp = $datetime.second;
    # $temp = (($temp - $temp.floor) * (10 ** digits)).Str;
    # $temp = transliterate( ('0' x ($temp.chars - digits)) ~ $temp);
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(:infix(Assign),
            left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
            right => RakuAST::ApplyPostfix.new(
                postfix => GetSecond,
                operand => Source
            )
        )
    ),
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(
            left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
            infix => Assign,
            right => RakuAST::ApplyPostfix.new(
                postfix => Stringify,
                operand => RakuAST::ApplyPostfix.new(
                    postfix => RakuAST::Call::Method.new( name => RakuAST::Name.from-identifier('floor')),
                    operand => RakuAST::ApplyInfix.new(
                        left => RakuAST::ApplyInfix.new(
                            left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
                            infix => RakuAST::Infix.new('-'),
                            right => RakuAST::ApplyPostfix.new(
                                postfix => RakuAST::Call::Method.new( name => RakuAST::Name.from-identifier('floor')),
                                operand => RakuAST::Var::Lexical.new('$DATETIMETEMP1')
                            )
                        ),
                        infix => RakuAST::Infix.new('*'),
                        right => RakuAST::IntLiteral.new(10 ** digits)
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