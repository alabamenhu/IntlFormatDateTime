use v6.d;
unit module F-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'F' formatter is the weekday-in-month formatter.
# This shows the number of times the weekday has occurred in the month.  (So, for the third wednesday, '3',
# for the second Sunday, '2', for the fifth saturday '5').  Only provides values from 1-5.

constant Source    = RakuAST::Var::Lexical.new('$datetime');
constant GetDay    = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('weekday-of-month'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

sub format-F($, \data) is export {
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => RakuAST::ApplyPostfix.new(
                operand => Source,
                postfix => GetDay
            )
        )
    )
}
