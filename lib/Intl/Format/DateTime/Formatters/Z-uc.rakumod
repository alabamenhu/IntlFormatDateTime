use v6.d;
unit module Z-uc;

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

proto sub format-Z ($, $) { * }

multi sub format-Z ($, \data) is export {
    use Intl::Format::DateTime::Formatters::x-lc;
    return format-x(4,data)
}
multi sub format-Z (4, \data) is export {
    use Intl::Format::DateTime::Formatters::O-uc;
    return format-O(4,data)
}
multi sub format-Z (5, \data) is export {
    use Intl::Format::DateTime::Formatters::X-uc;
    return format-X(5,data)
}
