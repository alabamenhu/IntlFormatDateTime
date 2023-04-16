use v6.d;
unit module l-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'l' formatter is a no-op formatter
#
# Per CLDR, this was historically used ot to indicate placement of a leapmonth
# in certain calendars.  However, this will now be handled through other means

sub format-l($,$) is export is pure {
    Empty
}