use v6.d;
unit module X-uc;

use experimental :rakuast;
use Intl::Format::DateTime::Util;
# The 'X' formatter is the ISO timezone format, with 'Z' when the offset is 0
#
# For 'X':     zero-padded hours obligatory, minutes optional only if not 0
# For 'XX':    zero-padded hours obligatory, minutes obligatory
# For 'XXX':   zero-padded hours obligatory, minutes obligatory, colon-separated
# For 'XXXX':  zero-padded hours obligatory, minutes obligatory, seconds optional
# For 'XXXXX': zero-padded hours obligatory, minutes obligatory, seconds optional, colon separated
#
# This cheats and uses a straight up if else block because I'm very lazy.
constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant GetTZ       = RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('offset'));

sub format-X (\length, \data) is export {
    use Intl::Format::DateTime::Formatters::x-lc;
    RakuAST::Statement::If.new(
        condition => RakuAST::ApplyInfix.new(
            left => RakuAST::IntLiteral.new(0),
            infix => RakuAST::Infix.new('=='),
            right => RakuAST::ApplyPostfix.new(
                postfix => GetTZ,
                operand => Source
            )
        ),
        then => RakuAST::Block.new( body =>
            RakuAST::Blockoid.new(
                RakuAST::StatementList.new(
                    concat-to-result-stmt(RakuAST::StrLiteral.new('Z'))
                )
            )
        ),
        else => RakuAST::Block.new( body =>
            RakuAST::Blockoid.new(
                RakuAST::StatementList.new(
                    |format-x(length,data)
                )
            )
        )
    )
}
