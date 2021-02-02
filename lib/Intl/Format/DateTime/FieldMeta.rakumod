use Intl::Format::DateTime::Constants;

class FieldMeta {
    has int $.type;
    has int $.distance;
}

my \fields = Map.new:
    'G',     FieldMeta.new( :type(ERA) :distance(SHORT)  ),
    'GG',    FieldMeta.new( :type(ERA) :distance(SHORT)  ),
    'GGG',   FieldMeta.new( :type(ERA) :distance(SHORT)  ),
    'GGGG',  FieldMeta.new( :type(ERA) :distance(LONG)   ),
    'GGGGG', FieldMeta.new( :type(ERA) :distance(NARROW) ),

    # ICU uses a linear search approach that sets min/max numbers,
    #
    'y',          FieldMeta.new( :type(YEAR), :distance(NUMERIC) ),
    'yy',         FieldMeta.new( :type(YEAR), :distance(NUMERIC) ),
    'yyy',        FieldMeta.new( :type(YEAR), :distance(NUMERIC) ),
    'yyyy',       FieldMeta.new( :type(YEAR), :distance(NUMERIC) ),
    'yyyyy',      FieldMeta.new( :type(YEAR), :distance(NUMERIC) ),
    'yyyyyy',     FieldMeta.new( :type(YEAR), :distance(NUMERIC) ),
    'yyyyyyy',    FieldMeta.new( :type(YEAR), :distance(NUMERIC) ),
    'yyyyyyyy',   FieldMeta.new( :type(YEAR), :distance(NUMERIC) ),
    'yyyyyyyyy',  FieldMeta.new( :type(YEAR), :distance(NUMERIC) ),
    'yyyyyyyyyy', FieldMeta.new( :type(YEAR), :distance(NUMERIC) ),

    'Y',          FieldMeta.new( :type(YEAR), :distance(NUMERIC + Δ) ),
    'YY',         FieldMeta.new( :type(YEAR), :distance(NUMERIC + Δ) ),
    'YYY',        FieldMeta.new( :type(YEAR), :distance(NUMERIC + Δ) ),
    'YYYY',       FieldMeta.new( :type(YEAR), :distance(NUMERIC + Δ) ),
    'YYYYY',      FieldMeta.new( :type(YEAR), :distance(NUMERIC + Δ) ),
    'YYYYYY',     FieldMeta.new( :type(YEAR), :distance(NUMERIC + Δ) ),
    'YYYYYYY',    FieldMeta.new( :type(YEAR), :distance(NUMERIC + Δ) ),
    'YYYYYYYY',   FieldMeta.new( :type(YEAR), :distance(NUMERIC + Δ) ),
    'YYYYYYYYY',  FieldMeta.new( :type(YEAR), :distance(NUMERIC + Δ) ),
    'YYYYYYYYYY', FieldMeta.new( :type(YEAR), :distance(NUMERIC + Δ) ),

    'u',          FieldMeta.new( :type(YEAR), :distance(NUMERIC + 2 * Δ) ),
    'uu',         FieldMeta.new( :type(YEAR), :distance(NUMERIC + 2 * Δ) ),
    'uuu',        FieldMeta.new( :type(YEAR), :distance(NUMERIC + 2 * Δ) ),
    'uuuu',       FieldMeta.new( :type(YEAR), :distance(NUMERIC + 2 * Δ) ),
    'uuuuu',      FieldMeta.new( :type(YEAR), :distance(NUMERIC + 2 * Δ) ),
    'uuuuuu',     FieldMeta.new( :type(YEAR), :distance(NUMERIC + 2 * Δ) ),
    'uuuuuuu',    FieldMeta.new( :type(YEAR), :distance(NUMERIC + 2 * Δ) ),
    'uuuuuuuu',   FieldMeta.new( :type(YEAR), :distance(NUMERIC + 2 * Δ) ),
    'uuuuuuuuu',  FieldMeta.new( :type(YEAR), :distance(NUMERIC + 2 * Δ) ),
    'uuuuuuuuuu', FieldMeta.new( :type(YEAR), :distance(NUMERIC + 2 * Δ) ),

    'r',          FieldMeta.new( :type(YEAR), :distance(NUMERIC + 3 * Δ) ),
    'rr',         FieldMeta.new( :type(YEAR), :distance(NUMERIC + 3 * Δ) ),
    'rrr',        FieldMeta.new( :type(YEAR), :distance(NUMERIC + 3 * Δ) ),
    'rrrr',       FieldMeta.new( :type(YEAR), :distance(NUMERIC + 3 * Δ) ),
    'rrrrr',      FieldMeta.new( :type(YEAR), :distance(NUMERIC + 3 * Δ) ),
    'rrrrrr',     FieldMeta.new( :type(YEAR), :distance(NUMERIC + 3 * Δ) ),
    'rrrrrrr',    FieldMeta.new( :type(YEAR), :distance(NUMERIC + 3 * Δ) ),
    'rrrrrrrr',   FieldMeta.new( :type(YEAR), :distance(NUMERIC + 3 * Δ) ),
    'rrrrrrrrr',  FieldMeta.new( :type(YEAR), :distance(NUMERIC + 3 * Δ) ),
    'rrrrrrrrrr', FieldMeta.new( :type(YEAR), :distance(NUMERIC + 3 * Δ) ),

    'U',     FieldMeta.new( :type(ERA) :distance(SHORT)  ),
    'UU',    FieldMeta.new( :type(ERA) :distance(SHORT)  ),
    'UUU',   FieldMeta.new( :type(ERA) :distance(SHORT)  ),
    'UUUU',  FieldMeta.new( :type(ERA) :distance(LONG)   ),
    'UUUUU', FieldMeta.new( :type(ERA) :distance(NARROW) ),


    'Q',     FieldMeta.new( :type(QUARTER) :distance(NUMERIC) ),
    'QQ',    FieldMeta.new( :type(QUARTER) :distance(NUMERIC) ),
    'QQQ',   FieldMeta.new( :type(QUARTER) :distance(SHORT)   ),
    'QQQQ',  FieldMeta.new( :type(QUARTER) :distance(LONG)    ),
    'QQQQQ', FieldMeta.new( :type(QUARTER) :distance(NARROW)  ),

    'q',     FieldMeta.new( :type(QUARTER) :distance(NUMERIC + Δ) ),
    'qq',    FieldMeta.new( :type(QUARTER) :distance(NUMERIC + Δ) ),
    'qqq',   FieldMeta.new( :type(QUARTER) :distance(SHORT   - Δ) ),
    'qqqq',  FieldMeta.new( :type(QUARTER) :distance(LONG    - Δ) ),
    'qqqqq', FieldMeta.new( :type(QUARTER) :distance(NARROW  - Δ) ),


    'M',     FieldMeta.new( :type(MONTH) :distance(NUMERIC) ),
    'MM',    FieldMeta.new( :type(MONTH) :distance(NUMERIC) ),
    'MMM',   FieldMeta.new( :type(MONTH) :distance(SHORT)   ),
    'MMMM',  FieldMeta.new( :type(MONTH) :distance(LONG)    ),
    'MMMMM', FieldMeta.new( :type(MONTH) :distance(NARROW)  ),

    'L',     FieldMeta.new( :type(MONTH) :distance(NUMERIC + Δ) ),
    'LL',    FieldMeta.new( :type(MONTH) :distance(NUMERIC + Δ) ),
    'LLL',   FieldMeta.new( :type(MONTH) :distance(SHORT   - Δ) ),
    'LLLL',  FieldMeta.new( :type(MONTH) :distance(LONG    - Δ) ),
    'LLLLL', FieldMeta.new( :type(MONTH) :distance(NARROW  - Δ) ),

    'l', FieldMeta.new( :type(MONTH) :distance(NUMERIC + Δ) ),


    'w',  FieldMeta.new( :type(WEEK-OF-YEAR) :distance(NUMERIC) ),
    'ww', FieldMeta.new( :type(WEEK-OF-YEAR) :distance(NUMERIC) ),


    'W', FieldMeta.new( :type(WEEK-OF-MONTH) :distance(NUMERIC) ),


    'E',      FieldMeta.new( :type(WEEKDAY) :distance(SHORT)   ),
    'EE',     FieldMeta.new( :type(WEEKDAY) :distance(SHORT)   ),
    'EEE',    FieldMeta.new( :type(WEEKDAY) :distance(SHORT)   ),
    'EEEE',   FieldMeta.new( :type(WEEKDAY) :distance(LONG)    ),
    'EEEEE',  FieldMeta.new( :type(WEEKDAY) :distance(NARROW)  ),
    'EEEEEE', FieldMeta.new( :type(WEEKDAY) :distance(SHORTER) ),

    'c',      FieldMeta.new( :type(WEEKDAY) :distance(NUMERIC + 2 * Δ) ),
    'cc',     FieldMeta.new( :type(WEEKDAY) :distance(NUMERIC + 2 * Δ) ),
    'ccc',    FieldMeta.new( :type(WEEKDAY) :distance(SHORT   - 2 * Δ) ),
    'cccc',   FieldMeta.new( :type(WEEKDAY) :distance(LONG    - 2 * Δ) ),
    'ccccc',  FieldMeta.new( :type(WEEKDAY) :distance(NARROW  - 2 * Δ) ),
    'cccccc', FieldMeta.new( :type(WEEKDAY) :distance(SHORTER - 2 * Δ) ),

    'e',      FieldMeta.new( :type(WEEKDAY) :distance(NUMERIC + Δ) ),
    'ee',     FieldMeta.new( :type(WEEKDAY) :distance(NUMERIC + Δ) ),
    'eee',    FieldMeta.new( :type(WEEKDAY) :distance(SHORT   - Δ) ),
    'eeee',   FieldMeta.new( :type(WEEKDAY) :distance(LONG    - Δ) ),
    'eeeee',  FieldMeta.new( :type(WEEKDAY) :distance(NARROW  - Δ) ),
    'eeeeee', FieldMeta.new( :type(WEEKDAY) :distance(SHORTER - Δ) ),


    'd',  FieldMeta.new( :type(DAY) :distance(NUMERIC) ),
    'dd', FieldMeta.new( :type(DAY) :distance(NUMERIC) ),

    'd',          FieldMeta.new( :type(DAY) :distance(NUMERIC + Δ) ),
    'dd',         FieldMeta.new( :type(DAY) :distance(NUMERIC + Δ) ),
    'ddd',        FieldMeta.new( :type(DAY) :distance(NUMERIC + Δ) ),
    'dddd',       FieldMeta.new( :type(DAY) :distance(NUMERIC + Δ) ),
    'ddddd',      FieldMeta.new( :type(DAY) :distance(NUMERIC + Δ) ),
    'dddddd',     FieldMeta.new( :type(DAY) :distance(NUMERIC + Δ) ),
    'ddddddd',    FieldMeta.new( :type(DAY) :distance(NUMERIC + Δ) ),
    'dddddddd',   FieldMeta.new( :type(DAY) :distance(NUMERIC + Δ) ),
    'ddddddddd',  FieldMeta.new( :type(DAY) :distance(NUMERIC + Δ) ),
    'dddddddddd', FieldMeta.new( :type(DAY) :distance(NUMERIC + Δ) ),


    'D',   FieldMeta.new( :type(DAY-OF-YEAR) :distance(NUMERIC) ),
    'DD',  FieldMeta.new( :type(DAY-OF-YEAR) :distance(NUMERIC) ),
    'DDD', FieldMeta.new( :type(DAY-OF-YEAR) :distance(NUMERIC) ),

    'F', FieldMeta.new( :type(DAY-OF-WEEK-IN-MONTH) :distance(NUMERIC) ),


    'a',     FieldMeta.new( :type(DAYPERIOD) :distance(SHORT)  ),
    'aa',    FieldMeta.new( :type(DAYPERIOD) :distance(SHORT)  ),
    'aaa',   FieldMeta.new( :type(DAYPERIOD) :distance(SHORT)  ),
    'aaaa',  FieldMeta.new( :type(DAYPERIOD) :distance(LONG)   ),
    'aaaaa', FieldMeta.new( :type(DAYPERIOD) :distance(NARROW) ),

    'b',     FieldMeta.new( :type(DAYPERIOD) :distance(SHORT  - Δ) ),
    'bb',    FieldMeta.new( :type(DAYPERIOD) :distance(SHORT  - Δ) ),
    'bbb',   FieldMeta.new( :type(DAYPERIOD) :distance(SHORT  - Δ) ),
    'bbbb',  FieldMeta.new( :type(DAYPERIOD) :distance(LONG   - Δ) ),
    'bbbbb', FieldMeta.new( :type(DAYPERIOD) :distance(NARROW - Δ) ),

    'B',     FieldMeta.new( :type(DAYPERIOD) :distance(SHORT  - 3 * Δ) ), # per ICU, b needs to
    'BB',    FieldMeta.new( :type(DAYPERIOD) :distance(SHORT  - 3 * Δ) ), # be closer to a than to B
    'BBB',   FieldMeta.new( :type(DAYPERIOD) :distance(SHORT  - 3 * Δ) ),
    'BBBB',  FieldMeta.new( :type(DAYPERIOD) :distance(LONG   - 3 * Δ) ),
    'BBBBB', FieldMeta.new( :type(DAYPERIOD) :distance(NARROW - 3 * Δ) ),


    'H',  FieldMeta.new( :type(HOUR) :distance(NUMERIC + 10 * Δ) ),
    'HH', FieldMeta.new( :type(HOUR) :distance(NUMERIC + 10 * Δ) ),

    'k',  FieldMeta.new( :type(HOUR) :distance(NUMERIC + 11 * Δ) ),
    'kk', FieldMeta.new( :type(HOUR) :distance(NUMERIC + 11 * Δ) ),

    'h',  FieldMeta.new( :type(HOUR) :distance(NUMERIC) ),
    'hh', FieldMeta.new( :type(HOUR) :distance(NUMERIC) ),

    'K',  FieldMeta.new( :type(HOUR) :distance(NUMERIC + Δ) ),
    'KK', FieldMeta.new( :type(HOUR) :distance(NUMERIC + Δ) ),


    'm',  FieldMeta.new( :type(MINUTE) :distance(NUMERIC) ),
    'mm', FieldMeta.new( :type(MINUTE) :distance(NUMERIC) ),


    's',  FieldMeta.new( :type(SECOND) :distance(NUMERIC) ),
    'ss', FieldMeta.new( :type(SECOND) :distance(NUMERIC) ),

    'A',          FieldMeta.new( :type(SECOND) :distance(NUMERIC + Δ) ),
    'AA',         FieldMeta.new( :type(SECOND) :distance(NUMERIC + Δ) ),
    'AAA',        FieldMeta.new( :type(SECOND) :distance(NUMERIC + Δ) ),
    'AAAA',       FieldMeta.new( :type(SECOND) :distance(NUMERIC + Δ) ),
    'AAAAA',      FieldMeta.new( :type(SECOND) :distance(NUMERIC + Δ) ),
    'AAAAAA',     FieldMeta.new( :type(SECOND) :distance(NUMERIC + Δ) ),
    'AAAAAAA',    FieldMeta.new( :type(SECOND) :distance(NUMERIC + Δ) ),
    'AAAAAAAA',   FieldMeta.new( :type(SECOND) :distance(NUMERIC + Δ) ),
    'AAAAAAAAA',  FieldMeta.new( :type(SECOND) :distance(NUMERIC + Δ) ),
    'AAAAAAAAAA', FieldMeta.new( :type(SECOND) :distance(NUMERIC + Δ) ),

    'S',          FieldMeta.new( :type(FRACTIONAL-SECOND) :distance(NUMERIC) ),
    'SS',         FieldMeta.new( :type(FRACTIONAL-SECOND) :distance(NUMERIC) ),
    'SSS',        FieldMeta.new( :type(FRACTIONAL-SECOND) :distance(NUMERIC) ),
    'SSSS',       FieldMeta.new( :type(FRACTIONAL-SECOND) :distance(NUMERIC) ),
    'SSSSS',      FieldMeta.new( :type(FRACTIONAL-SECOND) :distance(NUMERIC) ),
    'SSSSSS',     FieldMeta.new( :type(FRACTIONAL-SECOND) :distance(NUMERIC) ),
    'SSSSSSS',    FieldMeta.new( :type(FRACTIONAL-SECOND) :distance(NUMERIC) ),
    'SSSSSSSS',   FieldMeta.new( :type(FRACTIONAL-SECOND) :distance(NUMERIC) ),
    'SSSSSSSSS',  FieldMeta.new( :type(FRACTIONAL-SECOND) :distance(NUMERIC) ),
    'SSSSSSSSSS', FieldMeta.new( :type(FRACTIONAL-SECOND) :distance(NUMERIC) ),


    'v',    FieldMeta.new( :type(ZONE) :distance(SHORT  - 2 * Δ) ),
    'vv',   FieldMeta.new( :type(ZONE) :distance(LONG   - 2 * Δ) ),
    'vvv',  FieldMeta.new( :type(ZONE) :distance(LONG   - 2 * Δ) ),
    'vvvv', FieldMeta.new( :type(ZONE) :distance(LONG   - 2 * Δ) ),

    'z',    FieldMeta.new( :type(ZONE) :distance(SHORT) ),
    'zz',   FieldMeta.new( :type(ZONE) :distance(LONG) ),
    'zzz',  FieldMeta.new( :type(ZONE) :distance(LONG) ),
    'zzzz', FieldMeta.new( :type(ZONE) :distance(LONG) ),

    'Z',     FieldMeta.new( :type(ZONE) :distance(NARROW - Δ) ),
    'ZZ',    FieldMeta.new( :type(ZONE) :distance(NARROW - Δ) ),
    'ZZZ',   FieldMeta.new( :type(ZONE) :distance(NARROW - Δ) ),
    'ZZZZ',  FieldMeta.new( :type(ZONE) :distance(LONG   - Δ) ),
    'ZZZZZ', FieldMeta.new( :type(ZONE) :distance(SHORT  - Δ) ),

    'O',    FieldMeta.new( :type(ZONE) :distance(SHORT - Δ) ),
    'OO',   FieldMeta.new( :type(ZONE) :distance(SHORT - Δ) ),
    'OOO',  FieldMeta.new( :type(ZONE) :distance(SHORT - Δ) ),
    'OOOO', FieldMeta.new( :type(ZONE) :distance(LONG  - Δ) ),

    'V',    FieldMeta.new( :type(ZONE) :distance(SHORT - Δ    ) ),
    'VV',   FieldMeta.new( :type(ZONE) :distance(LONG  - Δ    ) ),
    'VVV',  FieldMeta.new( :type(ZONE) :distance(LONG  - Δ - 1) ), # -1 = Longer
    'VVVV', FieldMeta.new( :type(ZONE) :distance(LONG  - Δ - 2) ), # -2 = Longest

    'X',    FieldMeta.new( :type(ZONE) :distance(NARROW - Δ) ),
    'XX',   FieldMeta.new( :type(ZONE) :distance(SHORT  - Δ) ),
    'XXX',  FieldMeta.new( :type(ZONE) :distance(SHORT  - Δ) ),
    'XXXX', FieldMeta.new( :type(ZONE) :distance(LONG   - Δ) ),

    'x',    FieldMeta.new( :type(ZONE) :distance(NARROW - Δ) ),
    'xx',   FieldMeta.new( :type(ZONE) :distance(SHORT  - Δ) ),
    'xxx',  FieldMeta.new( :type(ZONE) :distance(SHORT  - Δ) ),
    'xxxx', FieldMeta.new( :type(ZONE) :distance(LONG   - Δ) ),
;

sub EXPORT {
    Map.new: '%fields' => fields;
}