use v6.d;
unit module y-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'y' formatter is the numeric year formatter
#
# All of the formatting codes effectively are "display at least
# this many digits" with the exception of 'yy' which means "show
# the abbreviated year".  Numbers are based on eras, so should
# always be positive (hence for Gregorian, if the year is < 1,
# abs($year) + 1.
#
# Todo: handle other eras
#
# At the moment, I do not believe that commas are generally used
# so we will avoid using a full on numeric formatter, but if
# that were the case, we could insert a modifier integral digit
# formatter from `Intl::Format::Number`.
constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Temp   = RakuAST::Var::Lexical.new('$DATETIMETEMP1');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');
constant Plus   = RakuAST::Infix.new('+');
constant GetYear = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('year'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-y ($, $) is export { * }

multi sub format-y(1,\data) {
    # This is the same as yyy+, but is more efficient
    |gregorian-to-temp,
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => Temp
        )
    )
}

multi sub format-y(2,\data) {
    |gregorian-to-temp,
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => RakuAST::ApplyInfix.new(
                left => Temp,
                infix => RakuAST::Infix.new('%'),
                right => RakuAST::IntLiteral.new(100)
            )
        )
    )
}

multi sub format-y(\padding,\data) {
    # Less efficient (but also less common)
    # $temp = $datetime.year.Str;
    # $result = transliterate('0' x (padding - $temp.chars) ) ~ $temp);
    |gregorian-to-temp,
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(:infix(Assign),
            left => Temp,
            right => RakuAST::ApplyPostfix.new(
                postfix => Stringify,
                operand => Temp
            )
        )
    ),
    concat-to-result-stmt( intl-digit-wrap(data.number-system,
        RakuAST::ApplyInfix.new(
            left => RakuAST::ApplyInfix.new(
                left => RakuAST::StrLiteral.new('0'),
                infix => RakuAST::Infix.new('x'),
                right => RakuAST::ApplyInfix.new(
                    left => RakuAST::IntLiteral.new(padding),
                    infix => RakuAST::Infix.new('-'),
                    right => RakuAST::ApplyPostfix.new(
                        operand => Temp,
                        postfix => RakuAST::Call::Method.new( name => RakuAST::Name.from-identifier('chars'))
                    )
                )
            ),
            infix => Concat,
            right => Temp
        )
    ))
}

sub gregorian-to-temp {
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::ApplyPostfix.new(
                operand => Source,
                postfix => GetYear,
            )
        )
    ),
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => RakuAST::IntLiteral.new(1),
                infix => Plus,
                right => RakuAST::Call::Name.new(
                    name => RakuAST::Name.from-identifier('abs'),
                    args => RakuAST::ArgList.new( Temp )
                )
            )
        ),
        condition-modifier => RakuAST::StatementModifier::If.new(
            RakuAST::ApplyInfix.new(
                left => Temp,
                infix => RakuAST::Infix.new('<'),
                right => RakuAST::IntLiteral.new(1)
            )
        )
    )
}