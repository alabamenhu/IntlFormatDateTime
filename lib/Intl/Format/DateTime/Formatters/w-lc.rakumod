use v6.d;
unit module w-lc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;

# The 'w' formatter is the week of year formatter, generally used with Y (week year).
# 'ww' is padded as needed with a single zero.

#`⟨⟨⟨⟨⟨⟨⟨⟨⟨
We cannot use '.week-number' because that assumes an ISO-based system as we must
account for different first-day-of-week and different minimum-week-lengths. To this
end, I have created a week-of-year calculation function.  This is based off of the
formulae provided in Calendrical Calculations by Edward M. Reingold and Nachum
Dershowitz (2018 Cambridge Press).  In the rawest form, the code in Raku should be:

   #| Provides a fixed date from which to work.  Uses a basic MJD formula and subtracts
   #| to reach the epoch of this unified date (1/1/1).
   sub rd(Dateish $date) --> Int {
       #= Provides a fixed date from which to do calculations (epoch: 1 AD January 1)
       # This function calculates the Julian day, and then subtracts a fixed epoch value (1721425).
       my $a = (14 - $date.month) div 12;
       my $y = $date.year + 4800 - $a;
       my $m = $date.month + 12 * $a - 3;
       $date.day + ((153 * $m + 2) div 5) + 365 * $y + ($y div 4) - ($y div 100) + ($y div 400) - 32045 - 1721425
   }

   #| Provides the day-of-the-week from the unified date (Monday = 1)
   sub day-of-week-from-fixed(Int $date) { $date mod 7 }

   #| Provides the unified date of the next weekday ($k, Monday = 1) from the given date
   sub kday-on-or-before(Int $k,Int $date) {
      $date - day-of-week-from-fixed($date - $k);
   }

   #| Obtains the first day-of-the-week ($k, Monday = 1) before the given date.
   sub kday-before(Int $k, Int $date) {
      kday-on-or-before($k, $date - 1);
   }

   #| Provides the day-of-the-week ($k, Monday = 1) some weeks ($n) forward or backwards in time from $g-date
   sub nth-kday(Int $n, Int  $k, DateTime $g-date) {
      # $k here should be the day BEFORE the first day of the week in a given calendar system.  Hence 0/7 (Sunday) for ISO
      if $n > 0 {
          (7 * $n) + kday-before($k, rd($g-date))
      } else {
          (7 * $n) + kday-after($k, rd($g-date))
      }
   }

   #| Provides the unified date from an ISO calendar
   sub fixed-from-iso(Int $year, Int $week, Int $day) {
       # The 28th here is chosen because of the 4 day minimum requirement.  To require a full week, set to 31
       # and for a single day, 25, or any other intermediate value for appropriate effect.
       nth-kday($week,7, Date.new($year - 1, 12, 28)) + $day;
   }

   #| Calculates the ISO date from a unified date (here, we take a Gregorian and immediately convert)
   sub iso-from-fixed($d) {
       my $date = rd $d;
       my $approx = floor( ($date - 4) / (146097/400) ) + 1;
       my $year = $approx + ($date >= fixed-from-iso($approx + 1, 1, 1));
       my $day = $date % 7;
       my $week = floor( (1/7) * ($date - fixed-from-iso($year,1,1)) ) + 1;
       return $year, $month, $day;
   }

Many of the subs are tail calls and can be inlined.  See the code blocks below for how things were
simplified.

This should be best put into a block so we can hide some of our additional methods and variables.
First we include a simplified rd, then our modified fixed-from-iso and iso-from-fixed functions.
Technically, these aren't ISO anymore, unless they are used with the ISO values of Monday-start,
four-day–minimum.  Then, set $DATETIMETEMP1 to the value as it's from outside the scope.  They
should probably be my-scoped, but that's not working right now in RakuAST.

    {
       &rd = { .. }
       &mod-fixed-from-iso { ... }
       &mod-iso-from-fixed { ... }
       my $date   = rd($datetime);
       my $approx = floor( ($date - 4) / (146097/400) ) + 1;
       my $year   = $approx + ($date >= mod-fixed-from-iso($approx + 1) );
       return floor( (1/7) * ($date - mod-fixed-from-iso($year)) ) + 1;
    }
    $result ~= $DATETIMETEMP1.Str; # pad accordingly

The same technique can be applied to calculate the year (obviously skipping the final
statement and returning the penultimate)
⟩⟩⟩⟩⟩⟩⟩⟩⟩


constant Result    = RakuAST::Var::Lexical.new('$result');
constant Source    = RakuAST::Var::Lexical.new('$datetime');
constant Temp      = RakuAST::Var::Lexical.new('$DATETIMETEMP1');
constant Assign    = RakuAST::Infix.new(':=');
constant Concat    = RakuAST::Infix.new('~');
constant Plus      = RakuAST::Infix.new('+');
constant Minus     = RakuAST::Infix.new('-');
constant IntDivide = RakuAST::Infix.new('div');
constant IntMod    = RakuAST::Infix.new('mod');
constant Multiply  = RakuAST::Infix.new('*');
constant GetDay    = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('day'));
constant GetMonth  = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('month'));
constant GetYear   = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('year'));
constant Stringify = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('Str'));

proto sub format-w($,$) is export { * }
multi sub format-w($, \data)  {
use Pretty::RAST;
    RakuAST::Statement::Expression.new(
        expression => calculation-block(data)
    ),
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => Temp,
        )
    )
}
multi sub format-w(2, \data) {
    RakuAST::Statement::Expression.new(
        expression => calculation-block(data)
    ),
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::Ternary.new(
            condition => RakuAST::ApplyInfix.new(
                left => Temp,
                infix => RakuAST::Infix.new('>'),
                right => RakuAST::IntLiteral.new(9),
            ),
            then => RakuAST::ApplyPostfix.new(
                operand => Temp,
                postfix => Stringify
            ),
            else => RakuAST::ApplyInfix.new(
                left => RakuAST::StrLiteral.new('0'),
                infix => Concat,
                right => RakuAST::ApplyPostfix.new(
                    operand => Temp,
                    postfix => Stringify
                )
            )
        )
    )
}

my sub inline-rd is pure {
   #sub rd ($date) {
   #my $a = (14 - $date.month) div 12;
   #my $y = $date.year + 4800 - $a;
   #$date.day
   #+ ((153 * ($date.month + 12 * $a - 3) + 2) div 5)
   #+ 365 * $y
   #+ ($y div 4)
   #+ ($y div 400)
   #- ($y div 100)
   #- 1753470
   ;
    RakuAST::Sub.new(
        #scope => 'my',
        name => RakuAST::Name.from-identifier('rd'),
        signature => RakuAST::Signature.new(
            parameters => (
                RakuAST::Parameter.new(target => RakuAST::ParameterTarget::Var.new('$year')),
                RakuAST::Parameter.new(target => RakuAST::ParameterTarget::Var.new('$month')),
                RakuAST::Parameter.new(target => RakuAST::ParameterTarget::Var.new('$day')),
            )
        ),
        body => RakuAST::Blockoid.new(
            RakuAST::StatementList.new(
                RakuAST::Statement::Expression.new( expression =>
                    RakuAST::VarDeclaration::Simple.new(:scope<my>,:name<$a>,
                        initializer => RakuAST::Initializer::Bind.new(
                            RakuAST::ApplyInfix.new(
                                left => RakuAST::ApplyInfix.new(
                                    left => RakuAST::IntLiteral.new(14),
                                    infix => Minus,
                                    right => RakuAST::Var::Lexical.new('$month')
                                ),
                                infix => IntDivide,
                                right => RakuAST::IntLiteral.new(12)
                            )
                        )
                    )
                ),
               RakuAST::Statement::Expression.new( expression =>
                    RakuAST::VarDeclaration::Simple.new(:scope<my>, :name<$y>,
                        initializer => RakuAST::Initializer::Bind.new(
                            RakuAST::ApplyInfix.new(
                                left => RakuAST::ApplyInfix.new(
                                    left => RakuAST::Var::Lexical.new('$year'),
                                    infix => Plus,
                                    right => RakuAST::IntLiteral.new(4800)
                                ),
                                infix => Minus,
                                right => RakuAST::Var::Lexical.new('$a')
                            )
                        )
                    )
                ),
                RakuAST::Statement::Expression.new( expression =>
                    RakuAST::Call::Name.new( name => RakuAST::Name.from-identifier('return'),
                        args => RakuAST::ArgList.new(
                            RakuAST::ApplyInfix.new(
                                left => RakuAST::ApplyInfix.new(
                                    left => RakuAST::ApplyInfix.new(
                                        left => RakuAST::ApplyInfix.new( # (153 * ($month + 12 * $a - 3) - 2) div 5
                                            left => RakuAST::ApplyInfix.new( # 153 * ($month + 12 * $a - 3) - 2
                                                left => RakuAST::ApplyInfix.new( # 153 * ($month + 12 * $a - 3)
                                                    left => RakuAST::IntLiteral.new(153),
                                                    infix => Multiply,
                                                    right => RakuAST::ApplyInfix.new( # ($month + 12 * $a) - 3
                                                        left => RakuAST::ApplyInfix.new( # $month + (12 * $a)
                                                            left => RakuAST::Var::Lexical.new('$month'),
                                                            infix => Plus,
                                                            right => RakuAST::ApplyInfix.new(  # 12 * $a
                                                                left => RakuAST::IntLiteral.new(12),
                                                                infix => Multiply,
                                                                right => RakuAST::Var::Lexical.new('$a')
                                                            ),
                                                        ),
                                                        infix => Minus,
                                                        right => RakuAST::IntLiteral.new(3)
                                                    )
                                                ),
                                                infix => Plus,
                                                right => RakuAST::IntLiteral.new(2)
                                            ),
                                            infix => IntDivide,
                                            right => RakuAST::IntLiteral.new(5),
                                        ),
                                        infix => Plus,
                                        right => RakuAST::ApplyInfix.new( # $day + ($y * 365)
                                            left => RakuAST::Var::Lexical.new('$day'),
                                            infix => Plus,
                                            right => RakuAST::ApplyInfix.new( # $y * 365
                                                left => RakuAST::Var::Lexical.new('$y'), infix => Multiply, right => RakuAST::IntLiteral.new(365)
                                            )
                                        ),
                                    ),
                                    infix => Plus,
                                    right => RakuAST::ApplyInfix.new( # ($y div 4) + ($y div 400)
                                        left => RakuAST::ApplyInfix.new( # $y div 4
                                            left => RakuAST::Var::Lexical.new('$y'), infix => IntDivide, right => RakuAST::IntLiteral.new(4)
                                        ),
                                        infix => Plus,
                                        right => RakuAST::ApplyInfix.new( # $y div 400
                                            left => RakuAST::Var::Lexical.new('$y'), infix => IntDivide, right => RakuAST::IntLiteral.new(400)
                                        )
                                    )
                                ),
                                infix => Minus, # ($y div 100) + 173470 (added because we subtract them, basically making both negative)
                                right => RakuAST::ApplyInfix.new(
                                    left => RakuAST::ApplyInfix.new(
                                        left => RakuAST::Var::Lexical.new('$y'), infix => IntDivide, right => RakuAST::IntLiteral.new(100)
                                    ),
                                    infix => Plus,
                                    right => RakuAST::IntLiteral.new(1753470)
                                )
                            )
                        )
                    )
                )
            )
        )
    )
}

# #| This is a modified fixed-from-iso function inlining all the math.
# #| It is only called with $week = 1, so
# sub modified-fixed-from-iso($year,$day,$required-days) {
#   # week is always one for our purpose
#   # Go back based on the number of required days.
#   # 4 required days (per ISO) is Dec 28th.
#   # 1 required day (as in US) is Dec 31st.
#   my $REQUIRED-DAYS = 4;
#   my $date = rd(Date.new($year - 1, 12, 32 - $REQUIRED-DAYS)) - 1;
#   7 + $day + ($date - ($date mod 7))
#}

sub inline-mod-fixed-from-iso(\data) {
    #sub mod-fixed-from-iso(Int $year) {
    #    my $date = rd( Date.new: $year - 1, 12, {24 + data.min-days}) - 1;
    #    8 + $date - (($date - {data.first-day - 1}) mod 7)
    #}
    RakuAST::Sub.new(
        #scope => 'my',
        name => RakuAST::Name.from-identifier('mod-fixed-from-iso'),
        signature => RakuAST::Signature.new(
            parameters => (
                RakuAST::Parameter.new(target => RakuAST::ParameterTarget::Var.new('$year')),
            )
        ),
        body => RakuAST::Blockoid.new(
            RakuAST::StatementList.new(
                RakuAST::Statement::Expression.new( expression =>
                    RakuAST::VarDeclaration::Simple.new(
                        scope => 'my',
                        name => '$date',
                        initializer => RakuAST::Initializer::Bind.new(
                            RakuAST::ApplyInfix.new(
                                left => RakuAST::Call::Name.new( name => RakuAST::Name.from-identifier('rd'),
                                    args => RakuAST::ArgList.new(
                                        RakuAST::ApplyInfix.new(
                                            left => RakuAST::Var::Lexical.new('$year'),
                                            infix => Minus,
                                            right => RakuAST::IntLiteral.new(1),
                                        ),
                                        RakuAST::IntLiteral.new(12),
                                        RakuAST::IntLiteral.new(24 + data.min-days-in-week)
                                    )
                                ),
                                infix => Minus,
                                right => RakuAST::IntLiteral.new(1)
                            )
                        )
                    )
                ),
                RakuAST::Statement::Expression.new( expression =>
                    RakuAST::Call::Name.new( name => RakuAST::Name.from-identifier('return'),
                        args => RakuAST::ArgList.new(
                            RakuAST::ApplyInfix.new(
                                left => RakuAST::ApplyInfix.new(
                                    left => RakuAST::IntLiteral.new(8),
                                    infix => Plus,
                                    right => RakuAST::Var::Lexical.new('$date'),
                                ),
                                infix => Minus,
                                right => RakuAST::ApplyInfix.new(
                                    right => RakuAST::IntLiteral.new(7),
                                    infix => IntMod,
                                    left => RakuAST::ApplyInfix.new(
                                        left => RakuAST::Var::Lexical.new('$date'),
                                        infix => Minus,
                                        right => RakuAST::IntLiteral.new(data.first-day-in-week - 1)
                                    )
                                )
                            )
                       )
                    )
                )
            )
        )
    )
}

sub set-temp-to-week {
#sub mod-iso-from-fixed($*FIRST-DAY, $*MIN-DAYS, $d) {
#    my $date = rd $d;
#    my $approx = floor( ($date - 4) / (146097/400) ) + 1;
#    my $year = $approx + ($date >= mod-fixed-from-iso($approx + 1) );
#    my $week = floor( (1/7) * ($date - mod-fixed-from-iso($year) ) ) + 1;
#   #return $year, $week, $day;
#    return $week;
#}
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::VarDeclaration::Simple.new(
            scope => 'my',
            name => '$date',
            initializer => RakuAST::Initializer::Bind.new(
                RakuAST::Call::Name.new( name => RakuAST::Name.from-identifier('rd'),
                    args => RakuAST::ArgList.new(
                        RakuAST::ApplyPostfix.new( :operand(Source), :postfix(GetYear)  ),
                        RakuAST::ApplyPostfix.new( :operand(Source), :postfix(GetMonth) ),
                        RakuAST::ApplyPostfix.new( :operand(Source), :postfix(GetDay)   ),
                    )
                )
            )
        )
    ),
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::VarDeclaration::Simple.new(
            scope => 'my',
            name => '$approx',
            initializer => RakuAST::Initializer::Bind.new(
                RakuAST::ApplyInfix.new(
                    left => RakuAST::IntLiteral.new(1),
                    infix => Plus,
                    right => RakuAST::Call::Name.new( name => RakuAST::Name.from-identifier('floor'),
                        args => RakuAST::ArgList.new(
                            RakuAST::ApplyInfix.new(
                                left => RakuAST::ApplyInfix.new(
                                    left => RakuAST::Var::Lexical.new('$date'),
                                    infix => Minus,
                                    right => RakuAST::IntLiteral.new(4)
                                ),
                                infix => RakuAST::Infix.new('/'),
                                right => RakuAST::ApplyInfix.new(
                                    left => RakuAST::IntLiteral.new(146097),
                                    right => RakuAST::IntLiteral.new(400),
                                    infix => RakuAST::Infix.new('/')
                                )
                            )
                        )
                    )
                )
            )
        )
    ),
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::VarDeclaration::Simple.new(
            scope => 'my',
            name => '$year',
            initializer => RakuAST::Initializer::Bind.new(
                RakuAST::ApplyInfix.new(
                    left => RakuAST::Var::Lexical.new('$approx'),
                    infix => Plus,
                    right => RakuAST::ApplyInfix.new(
                        left => RakuAST::Var::Lexical.new('$date'),
                        infix => RakuAST::Infix.new('>='),
                        right => RakuAST::Call::Name.new(
                            name => RakuAST::Name.from-identifier('mod-fixed-from-iso'),
                            args => RakuAST::ArgList.new(
                                RakuAST::ApplyInfix.new(
                                    left => RakuAST::Var::Lexical.new('$approx'),
                                    infix => Plus,
                                    right => RakuAST::IntLiteral.new(1),
                                )
                            )
                        )
                    )
                )
            )
        )
    ),
    RakuAST::Statement::Expression.new(expression =>
        RakuAST::ApplyInfix.new(
            left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
                left => RakuAST::IntLiteral.new(1),
                infix => Plus,
                right => RakuAST::Call::Name.new(
                    name => RakuAST::Name.from-identifier('floor'),
                    args => RakuAST::ArgList.new(
                        RakuAST::ApplyInfix.new(
                            left => RakuAST::ApplyInfix.new(
                                left => RakuAST::IntLiteral.new(1),
                                infix => RakuAST::Infix.new('/'),
                                right => RakuAST::IntLiteral.new(7),
                            ),
                            infix => Multiply,
                            right => RakuAST::ApplyInfix.new(
                                left => RakuAST::Var::Lexical.new('$date'),
                                infix => Minus,
                                right => RakuAST::Call::Name.new(
                                    name => RakuAST::Name.from-identifier('mod-fixed-from-iso'),
                                    args => RakuAST::ArgList.new( RakuAST::Var::Lexical.new('$year'))
                                )
                            )
                        )
                    )
                )
            )
        )
    )
}

sub calculation-block(\data) {
    RakuAST::Block.new( body => RakuAST::Blockoid.new( RakuAST::StatementList.new(
        RakuAST::Statement::Expression.new(expression => inline-rd),
        RakuAST::Statement::Expression.new(expression => inline-mod-fixed-from-iso(data)),
        |set-temp-to-week
    )))
}