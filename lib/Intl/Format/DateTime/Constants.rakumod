unit module Constants;

# These could probably be enums, but these aren't really for external consumption
# and so they should be a teeny bit faster

constant ERA                  is export = 0;
constant YEAR                 is export = 1;
constant QUARTER              is export = 2;
constant MONTH                is export = 3;
constant WEEK-OF-YEAR         is export = 4;
constant WEEK-OF-MONTH        is export = 5;
constant WEEK                 is export = 6;
constant WEEKDAY              is export = 7;
constant DAY                  is export = 8;
constant DAY-OF-YEAR          is export = 9;
constant DAY-OF-WEEK-IN-MONTH is export = 10;
constant DAYPERIOD            is export = 11;
constant HOUR                 is export = 12;
constant MINUTE               is export = 13;
constant SECOND               is export = 14;
constant FRACTIONAL-SECOND    is export = 15;
constant ZONE                 is export = 16;

# These are used to calculate the variance between two fields of similar types
# such that narrow is closer to shorter is closer to shorter, etc, and numerics
# are very distant from from the alphabetics.  The Δ allows for even more granular
# control.  These are copied shamelessly from ICU:
#   Values:  https://github.com/unicode-org/icu/blob/a84fdd0e903fb20acd93ed186a0da4c0c071a0e6/icu4c/source/i18n/dtptngen_impl.h#L95
#   Applied: https://github.com/unicode-org/icu/blob/b82dc88148f92cd5c9f7bd075feb9d238a86d8d7/icu4c/source/i18n/dtptngen.cpp#L145
constant EXTRA   is export =  0x10000; # Should generally produce an automatic failure
constant MISSING is export =  0x01000; # Almost as bad (except we can add additional elements)
constant NUMERIC is export =  0x00100; # Numeric is the next level down
constant NARROW  is export = -0x00101; # Alphabetic is negative to guarantee a large jump from numeric
constant SHORTER is export = -0x00102; # Goes in order to prefer the one most similar in size
constant SHORT   is export = -0x00103; #
constant LONG    is export = -0x00104; #
constant Δ       is export =  0x00010; # For even smaller tweaks: add to numeric, subtract from letters
