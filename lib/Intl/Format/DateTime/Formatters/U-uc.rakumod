use v6.d;
unit module U-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'U' formatter is the cyclic year formatter
#
# U, UU, and UUU are abbreviated, with UUUU and UUUUU being wide and narrow.
# Currently, only abbreviated names are provided in CLDR.  That said, per CLDR
#
#     If the calendar does not provide cyclic year name data, or if the year
#     value to be formatted is out of the range of years for which cyclic name
#     data is provided, then numeric formatting is used (behaves like 'y').
#
# Because we currently only implement Gregorian calendars... we cheat, import y
# and will format as just 'y':

sub format-U ($, \data) is export {
    use Intl::Format::DateTime::Formatters::y-lc;
    return format-y(1,data)
}
