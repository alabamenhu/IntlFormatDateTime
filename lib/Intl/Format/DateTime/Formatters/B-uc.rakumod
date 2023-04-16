use v6.d;
unit module B-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'B' formatter is the time period formatter using localized values (e.g. in the morning, afternoon)
#
# 'B', 'BB', and 'BBB' are identical, so specific versions are provided for
# 4 and 5, and then 1-3 is placed in a catch all.
#
# While it may be possible to optimize this a lot more, for now we check for == noon/midnight (if used)
# and then go in order checking for values < something.  Most languages only have 3-4 periods, so
# trying to binary search it will provide minimal improvement in speed at the cost of a lot of extra
# complexity in the AST formation.
#
# For future development: should am/pm only be shown at 12:00:00.0̅?
# CLDR documentation isn't clear.  Currently, we only look at hour/min.

constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');

# $result = $result ~ ($datetime.hour < 12
#   ?? day-periods.format.abbreviated.am
#   !! day-periods.format.abbreviated.pm
sub format-B(\width,\data) is export {
    my \rules = data.dates.day-period-rules.standard;
    my @at-rules;
    my @range-rules;

    # Process the periods to be merged into a long ternary statement
    constant periods = <midnight night1 night2 morning1 morning2 noon afternoon1 afternoon2 evening1 evening2>;
    for periods -> \period {
        my \rule = rules{period};
        if rule.used {
            if rule.at == -1 {
                # The rule is a period if this is -1
                @range-rules.push: %(:type(period), :end(rule.before) );
                @range-rules.push: %(:type(period), :end(3600)        )
                    if rule.from > rule.before
            } else {
                # The rule is punctual (e.g. noon/midnight)
                @at-rules.push: %( :type(period), :time(rule.at) )
            }
        }
        @range-rules = @range-rules.sort(*<end>);
    }

    # While not common, we fall back to b formatters (ᴀᴍ/ᴘᴍ with noon/midnight)
    # in the case that the language does not yet have any periods.  Hacky but
    # no reason to double up the work.
    unless @range-rules {
        use Intl::Format::DateTime::Formatters::b-lc;
        return &format-b(width,data);
    }

    # Choose the terms that we'll use
    my \terms = width > 4
        ?? data.calendar.day-periods.format.narrow
        !! width == 4
            ?? data.calendar.day-periods.format.wide
            !! data.calendar.day-periods.format.abbreviated;

    # The latest time period will be our default
    my $ternary := RakuAST::StrLiteral.new(terms{@range-rules.pop<type>});

    # Cycle through all ranged ones from the end forward
    while @range-rules {
        my %rule = @range-rules.pop;
        $ternary := RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
                infix => RakuAST::Infix.new('<'),
                right => RakuAST::IntLiteral.new(%rule<end>)
            ),
            then => RakuAST::StrLiteral.new(terms{%rule<type>}),
            else => $ternary
        )
    }

    # Now handle the exact times (do these first because they can be in the middle
    # of one of the ranged ones.
    while @at-rules {
        my %rule = @at-rules.pop;
        $ternary := RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
                infix => RakuAST::Infix.new('=='),
                right => RakuAST::IntLiteral.new(%rule<time>)
            ),
            then => RakuAST::StrLiteral.new(terms{%rule<type>}),
            else => $ternary
        )
    }

    return
    RakuAST::Statement::Expression.new(expression =>
        RakuAST::ApplyInfix.new(
            left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => RakuAST::ApplyPostfix.new(
                    postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('minute')),
                    operand => Source,
                ),
                infix => RakuAST::Infix.new('+'),
                right => RakuAST::ApplyInfix.new(
                    left => RakuAST::IntLiteral.new(60),
                    infix => RakuAST::Infix.new('*'),
                    right => RakuAST::ApplyPostfix.new(
                        postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('hour')),
                        operand => Source
                    )
                )
            )
        )
    ),
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(
            left => Result,
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => Result,
                infix => Concat,
                right => $ternary
            )
        )
    )
}