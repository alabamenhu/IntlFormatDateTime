use v6.d;
unit module O-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'O' formatter is the localized GMT formatter
#
# For 'O':     use the short form (+/- hour)
# For 'OOOO':  use the long form (+/- hour:minute)
#
# The other lengths are not used.
#
# For the short format, no pattern is provided, and we have to cheat to create it
# (basically, find the H and M runs, remove the M run and any text between the H
# and M.  It assumes that short = H and long = HH and mm.  This may not be 100%
# accurate but I'm not sure a better way.
#
# Note that per CLDR:
#     Localized GMT format: A constant, specific offset from GMT (or UTC), which
#     may be in a translated form. There are two styles for this. The first is
#     used when there is an explicit non-zero offset from GMT; this style is
#     specified by the <gmtFormat> element and <hourFormat> element. The long
#     format always uses 2-digit hours field and minutes field, with optional
#     2-digit seconds field. The short format is intended for the shortest
#     representation and uses hour fields without leading zero, with optional
#     2-digit minutes and seconds fields. The digits used for hours, minutes and
#     seconds fields in this format are the locale's default decimal digits
# Thus
# TODO: use localized digits

constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Temp   = RakuAST::Var::Lexical.new('$DATETIMETEMP1');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');
constant GetTZ     = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('offset'));
constant GetTZHour = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('offset-in-hours'));
constant GetTZMinute = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('offset-in-minutes'));
constant Intify    = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Int'));
constant GetAbs    = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('abs'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));
constant HourItem   = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('head'));
constant MinuteItem = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('tail'));

#`<<<proto format-O($,$) is export { * }
multi sub format-O (\length, \data) {
    my $gmt-format = data.dates.timezone-names.gmt-format;
    # Not accurate, but for some reason, English's is giving a wrong value in CLDR.  Should be …….gmt-zero-format
    my $zero-string = RakuAST::StrLiteral.new($gmt-format.subst('{0}',''));

    RakuAST::Statement::Expression.new(expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::ApplyPostfix.new(
                postfix => Intify,
                    operand => RakuAST::ApplyPostfix.new(
                    postfix => GetTZHour,
                    operand => Source
                )
            )
        )
    ),
    RakuAST::Statement::If.new(
        condition => RakuAST::ApplyInfix.new(
            left => RakuAST::IntLiteral.new(0),
            infix => RakuAST::Infix.new('=='),
            right => Temp
        ),
        then => RakuAST::Block.new( body =>
            RakuAST::Blockoid.new(
                RakuAST::StatementList.new(
                    concat-to-result-stmt($zero-string)
                )
            )
        ),
        else => RakuAST::Block.new( body =>
            RakuAST::Blockoid.new(
                RakuAST::StatementList.new(
                    concat-to-result-stmt(
                        one-term-replace(
                            $gmt-format,
                            '{0}',
                            RakuAST::ApplyInfix.new(
                                left => RakuAST::Ternary.new(
                                    condition => RakuAST::ApplyInfix.new(
                                        left => Temp,
                                        infix => RakuAST::Infix.new('<'),
                                        right => RakuAST::IntLiteral.new(0)
                                    ),
                                    then => RakuAST::StrLiteral.new('-'),
                                    else => RakuAST::StrLiteral.new('+'),
                                ),
                                infix => Concat,
                                right => RakuAST::ApplyPostfix.new(
                                    postfix => Stringify,
                                    operand => RakuAST::ApplyPostfix.new(
                                        postfix => GetAbs,
                                        operand => Temp
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    )
}>>>

sub format-O (\width, \data) is export {
    my $gmt-format = data.dates.timezone-names.gmt-format;
    # Not accurate, but for some reason, English's is giving a wrong value in CLDR.  Should be …….gmt-zero-format
    my $zero-string = RakuAST::StrLiteral.new($gmt-format.subst('{0}',''));
    my $hour-format = data.dates.timezone-names.hour-format;
    my ($positive, $negative) = $hour-format.split(';');

    RakuAST::Statement::Expression.new(expression =>
        RakuAST::ApplyInfix.new(
            left => Temp,
            infix => Assign,
            right => RakuAST::ApplyPostfix.new(
                postfix => Intify,
                    operand => RakuAST::ApplyPostfix.new(
                    postfix => GetTZMinute,
                    operand => Source
                )
            )
        )
    ),
    RakuAST::Statement::If.new(
        condition => RakuAST::ApplyInfix.new(
            left => RakuAST::IntLiteral.new(0),
            infix => RakuAST::Infix.new('=='),
            right => Temp
        ),
        then => RakuAST::Block.new( body =>
            RakuAST::Blockoid.new(
                RakuAST::StatementList.new(
                    concat-to-result-stmt($zero-string)
                )
            )
        ),
        else => RakuAST::Block.new( body =>
            RakuAST::Blockoid.new(
                RakuAST::StatementList.new(
                    RakuAST::Statement::Expression.new( expression =>
                        RakuAST::ApplyInfix.new(
                            left => Temp,
                            infix => Assign,
                            right => RakuAST::ApplyListInfix.new(
                                infix => RakuAST::Infix.new(','),
                                operands => (
                                    RakuAST::ApplyPostfix.new(
                                        postfix => Intify,
                                        operand => RakuAST::ApplyInfix.new(
                                            left => Temp,
                                            infix => RakuAST::Infix.new('/'),
                                            right => RakuAST::IntLiteral.new(60)
                                        )
                                    ),
                                    RakuAST::ApplyPostfix.new(
                                        postfix => Intify,
                                        operand => RakuAST::ApplyInfix.new(
                                            left => RakuAST::ApplyPostfix.new(
                                                postfix => GetAbs,
                                                operand => Temp,
                                            ),
                                            infix => RakuAST::Infix.new('%'),
                                            right => RakuAST::IntLiteral.new(60)
                                        )
                                    ),
                                )
                            )
                        )
                    ),
                    concat-to-result-stmt(
                        one-term-replace(
                            $gmt-format,
                            '{0}',
                            RakuAST::Ternary.new(
                                condition => RakuAST::ApplyInfix.new(
                                    left => RakuAST::ApplyPostfix.new(
                                        postfix => HourItem,
                                        operand => Temp
                                    ),
                                    infix => RakuAST::Infix.new('<'),
                                    right => RakuAST::IntLiteral.new(0)
                                ),
                                then => (width == 4 ?? hour-minute-formatter($negative) !! hour-formatter($negative) ),
                                else => (width == 4 ?? hour-minute-formatter($positive) !! hour-formatter($positive) ),
                            ),
                        )
                    )
                )
            )
        )
    )
}










sub one-term-replace($haystack, $needle, $replace) {
    my $initial-offset = $haystack.index($needle) // die 'GMT replacement value malformed';
    my $final-offset = $initial-offset + $needle.chars;

    if $initial-offset == 0 {
        # Replace in the end
        return RakuAST::ApplyInfix.new(
            left  => $replace,
            infix => Concat,
            right => RakuAST::StrLiteral.new($haystack.substr($final-offset)),
        )
    } elsif $final-offset == $haystack.chars {
        # Replace at the beginning
        return RakuAST::ApplyInfix.new(
            left => RakuAST::StrLiteral.new($haystack.substr(0,$initial-offset)),
            infix => Concat,
            right => $replace
        )
    } else {
        # Replace in the middle
        # Replace in the end
        return RakuAST::ApplyInfix.new(
            left => RakuAST::StrLiteral.new($haystack.substr(0,$initial-offset)),
            infix => Concat,
            right => RakuAST::ApplyInfix.new(
                left  => $replace,
                infix => Concat,
                right => RakuAST::StrLiteral.new($haystack.substr($final-offset)),
            )
        )
    }
}


sub hour-minute-formatter($gmt) {
    my $hour-start   = $gmt.index('H');
    my $minute-start = $gmt.index('m');
    my $hour-end = $hour-start;
    my $minute-end = $minute-start;
    $hour-end++   while $gmt.substr($hour-end,  1) eq 'H';
    $minute-end++ while $gmt.substr($minute-end,1) eq 'm';
    die "Need to update GMT formatter 'OOOO' due to weird min/hour formatting" if $minute-start < $hour-end;

    my $start-string = $gmt.substr(0,$hour-start);
    my $middle-string = $gmt.substr($hour-end, $minute-start - $hour-end);
    my $end-string = $gmt.substr($minute-end);

    # Go backwards, beginning with the final string
    my $result := RakuAST::StrLiteral.new($end-string);
    $result := RakuAST::ApplyInfix.new(
        left => RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    operand => Temp,
                    postfix => MinuteItem
                ),
                infix => RakuAST::Infix.new('>'),
                right => RakuAST::IntLiteral.new(9),
            ),
            then => RakuAST::ApplyPostfix.new(
                operand => RakuAST::ApplyPostfix.new(
                    operand => Temp,
                    postfix => MinuteItem
                ),
                postfix => Stringify
            ),
            else => RakuAST::ApplyInfix.new(
                left => RakuAST::StrLiteral.new('0'),
                infix => Concat,
                right => RakuAST::ApplyPostfix.new(
                    operand => RakuAST::ApplyPostfix.new(
                        operand => Temp,
                        postfix => MinuteItem
                    ),
                    postfix => Stringify
                )
            )
        ),
        infix => Concat,
        right => $result
    );

    # Now add in the colon/intermediate
    $result := RakuAST::ApplyInfix.new(
        left => RakuAST::StrLiteral.new($middle-string),
        infix => Concat,
        right => $result
    );

    # Now add in the hour
    $result := RakuAST::ApplyInfix.new(
        left => RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    postfix => GetAbs,
                    operand => RakuAST::ApplyPostfix.new(
                        operand => Temp,
                        postfix => HourItem
                    ),
                ),
                infix => RakuAST::Infix.new('>'),
                right => RakuAST::IntLiteral.new(9),
            ),
            then => RakuAST::ApplyPostfix.new(
                operand => RakuAST::ApplyPostfix.new(
                    postfix => GetAbs,
                    operand => RakuAST::ApplyPostfix.new(
                        operand => Temp,
                        postfix => HourItem
                    ),
                ),
                postfix => Stringify
            ),
            else => RakuAST::ApplyInfix.new(
                left => RakuAST::StrLiteral.new('0'),
                infix => Concat,
                right => RakuAST::ApplyPostfix.new(
                    operand => RakuAST::ApplyPostfix.new(
                        postfix => GetAbs,
                        operand =>  RakuAST::ApplyPostfix.new(
                            operand => Temp,
                            postfix => HourItem
                        ),
                    ),
                    postfix => Stringify
                )
            )
        ),
        infix => Concat,
        right => $result
    );
    # Now add in the initial string
    $result := RakuAST::ApplyInfix.new(
        left => RakuAST::StrLiteral.new($start-string),
        infix => Concat,
        right => $result
    );

    return $result;
}

# Almost the same, except no padding or minutes
sub hour-formatter($gmt) {
    my $hour-start   = $gmt.index('H');
    my $minute-start = $gmt.index('m');
    my $hour-end = $hour-start;
    my $minute-end = $minute-start;
    $hour-end++   while $gmt.substr($hour-end,  1) eq 'H';
    $minute-end++ while $gmt.substr($minute-end,1) eq 'm';
    die "Need to update GMT formatter 'OOOO' due to weird min/hour formatting" if $minute-start < $hour-end;

    my $start-string = $gmt.substr(0,$hour-start);
    my $middle-string = $gmt.substr($hour-end, $minute-start - $hour-end);
    my $end-string = $gmt.substr($minute-end);

    # Go backwards, beginning with the final string
    my $result := RakuAST::StrLiteral.new($end-string);

    # Now add in the hour
    $result := RakuAST::ApplyInfix.new(
        left => RakuAST::ApplyPostfix.new(
            operand => RakuAST::ApplyPostfix.new(
                postfix => GetAbs,
                operand => RakuAST::ApplyPostfix.new(
                    operand => Temp,
                    postfix => HourItem
                ),
            ),
            postfix => Stringify
        ),
        infix => Concat,
        right => $result
    );
    # Now add in the initial string
    $result := RakuAST::ApplyInfix.new(
        left => RakuAST::StrLiteral.new($start-string),
        infix => Concat,
        right => $result
    );

    return $result;
}
