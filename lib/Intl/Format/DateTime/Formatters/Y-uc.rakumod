use v6.d;
unit module Y-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'Y' formatter is the numeric year formatter for week calendars
#
# All of the formatting codes effectively are "display at least
# this many digits" with the exception of 'YY' which means "show
# the abbreviated year".  These numbers should be localized,
# At the moment, I do not believe that commas are generally used
# so we will avoid using a full on numeric formatter, but if
# that were the case, we could insert a modifier integral digit
# formatter from `Intl::Format::Number`.
#
# The complexity of calling this is substantial.  See the description
# provided in w-lc.rakumod.  Changes to either file should change the other.
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

proto sub format-Y ($, $) is export { * }

multi sub format-Y(1,\data) {
    # This is basically the same as YYY+, but is more efficient because no padding
    RakuAST::Statement::Expression.new(
        expression => calculation-block(data)
    ),
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => Temp
        )
    )
}

multi sub format-Y(2,\data) {
    RakuAST::Statement::Expression.new(
        expression => calculation-block(data)
    ),
    concat-to-result-stmt intl-digit-wrap(data.number-system,
        RakuAST::ApplyPostfix.new(
            postfix => Stringify,
            operand => RakuAST::ApplyInfix.new(
                left => Temp,
                infix => IntMod,
                right => RakuAST::IntLiteral.new(100)
            )
        )
    )
}

multi sub format-Y(\padding,\data) {
    # Less efficient (but also less common)
    # $temp = $datetime.year.Str;
    # $result = transliterate('0' x (padding - $temp.chars) ) ~ $temp);
    RakuAST::Statement::Expression.new(
        expression => calculation-block(data)
    ),
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(:infix(Assign),
            left => Temp,
            right => RakuAST::ApplyPostfix.new(
                postfix => Stringify,
                operand => Temp
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
                    infix => Minus,
                    right => RakuAST::ApplyPostfix.new(
                        operand => Temp,
                        postfix => RakuAST::Call::Method.new( name => RakuAST::Name.from-identifier('chars'))
                    )
                )
            ),
            infix => Concat,
            right => Temp
        )
    ))
}



# STOP
# Before editing the code below, ensure you have read the documentation in w-lc.rakumod
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
        RakuAST::ApplyInfix.new(
            left => RakuAST::Var::Lexical.new('$DATETIMETEMP1'),
            infix => Assign,
            right => RakuAST::ApplyInfix.new(
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
}

sub calculation-block(\data) {
    RakuAST::Block.new( body => RakuAST::Blockoid.new( RakuAST::StatementList.new(
        RakuAST::Statement::Expression.new(expression => inline-rd),
        RakuAST::Statement::Expression.new(expression => inline-mod-fixed-from-iso(data)),
        |set-temp-to-week
    )))
}