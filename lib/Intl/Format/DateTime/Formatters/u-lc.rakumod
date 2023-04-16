use v6.d;
unit module u-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'u' formatter is the numeric supra-year formatter
#
# In this form, the year ought to display as a single running number, including negative.
# For instance, in Julian/Gregorian calendars, 1 AD is 1, but 5 BC is -4 (5 BC would be 5
# in the y formatter).  No special treatment for 'uu'.
#
# For now, we use just a '-' but this should eventually incorporate the locale's minus sign
# I'm loathe to incorporate all of the number formatting data just for this one small item.
# TODO: find a counter example to see if anyone uses anything other than (minus sign) (integer).

constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');
constant GetYear = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('year'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));


sub format-u(\padding,\data) is export {
    # This works for gregorian -- may need adjusting for other calendar systems later.
    # TODO: Adjust for other calendar system
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(:infix(Assign),
            left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
            right => RakuAST::ApplyPostfix.new(
                postfix => Stringify,
                operand => RakuAST::ApplyPostfix.new(
                    postfix => GetYear,
                    operand => Source,
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
                    left => RakuAST::IntLiteral.new(padding),
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
