use v6.d;
unit module Util;
use experimental :rakuast;
constant Result = RakuAST::Var::Lexical.new('$result');
constant Source = RakuAST::Var::Lexical.new('$datetime');
constant Assign = RakuAST::Infix.new(':=');
constant Concat = RakuAST::Infix.new('~');

#| If necessary, wraps in a call to transliterate the decimal digits.
#| Otherwise, a pass-through noop.
sub intl-digit-wrap(\number-system,\node) is export {
    number-system eq 'latn'
        ?? node
        !! RakuAST::Call::Name.new(
            name => RakuAST::Name.from-identifier('transliterate'),
            args => RakuAST::ArgList.new(node)
        )
}

sub concat-to-result-stmt($x) is export {
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::ApplyInfix.new(:left(Result), :infix(Assign),
            right => RakuAST::ApplyInfix.new(:left(Result), :infix(Concat), :right($x))
        )
    )
}

#| Wraps a list in a block with required intermediate elements
sub block-blockoid-statement-list(*@items) is pure {
    RakuAST::Block.new(
        body => RakuAST::Blockoid.new(
            RakuAST::StatementList.new: |@items
        )
    )
}

#| Wraps a list in a blockoid with required intermediate elements
sub blockoid-statement-list(*@items) is pure {
    RakuAST::Blockoid.new(RakuAST::StatementList.new: |@items)
}

use Intl::LanguageTag;
class CLDR-Data is export {
    has $.start-digit;
    has $.lang;
    has $.language;
    has $.dates;
    has $.calendar;
    has $.number-system;
    has $.first-day-in-week;
    has $.min-days-in-week;
    method new(LanguageTag() $language) {
        use Intl::CLDR;
        my $lang := cldr{$language};
        my $dates := $lang.dates;
        my $calendar := $dates.calendars.gregorian;
        my $number-system := $lang.numbers.numbering-systems.default;
        # hacky for now
        my $first-day-in-week;
        if $language.extensions<u><fw> -> $day {
            $first-day-in-week = %(:0sun, :1mon, :2tue, :3wed, :4thu, :5fri, :6sat){$day}
        } else {
            constant Monday = <001 AD AI AL AM AN AR AT AU AX AZ BA BE BG BM BN BY CH CL CM CN CR CY CZ
		  	    DE DK EC EE ES FI FJ FO FR GB GE GF GP GR HR HU IE IS IT KG KZ LB LI LK LT LU LV
			    MC MD ME MK MN MQ MY NL NO NZ PL RE RO RS RU SE SI SK SM TJ TM TR UA UY UZ VA VN XK>.Set;
		    constant Friday = <MV>.Set;
		    constant Saturday = <AE AF BH DJ DZ EG IQ IR JO KW LY OM QA SD SY>.Set;
            constant Sunday = <AG AS BD BR BS BT BW BZ CA CO DM DO ET GT GU HK HN ID IL IN JM JP KE KH KR LA
                MH MM MO MT MX MZ NI NP PA PE PH PK PR PT PY SA SG SV TH TT TW UM US VE VI WS YE ZA ZW>.Set;
            with $language.region.Str {
                if Sunday{$_}      { $first-day-in-week = 0 }
                elsif Friday{$_}   { $first-day-in-week = 5 }
                elsif Saturday{$_} { $first-day-in-week = 6 }
                else               { $first-day-in-week = 1 }
            } else {
                $first-day-in-week = 1;
            }
        }

        constant Four = <AD AN AT AX BE BG CH CZ DE DK EE ES FI FJ FO FR GB GF GG GI GP GR
			HU IE IM IS IT JE LI LT LU MC MQ NL NO PL PT RE RU SE SJ SK SM VA>.Set;
		my $min-days-in-week = Four{$language.region.Str} ?? 4 !! 1;


        self.bless: :$lang, :$language, :$dates, :$calendar, :$number-system, :$first-day-in-week, :$min-days-in-week;
    }
}

# Generate the following using the following (from cldr supplement)
# "numberingSystems.xml".IO.lines.grep(/numeric/)
#     .map(*.match: /'id="'(<.alpha>+).*?'digits="'['&#x'(<[0..9A..F]>+)|(.)]/)
#     .map({':'~.[0]~'('~(.[1].substr(0,1) eq <123456789ABCDEF>.comb.any ?? .[1].Str.parse-base(16) !! .[1].ord)~'), '})
#| The offset for the 0 digit for a number system
constant %digit-offset =  :adlm(125264),    :ahom(71472),     :arab(1632),     :arabext(1776),    :bali(6992),
        :beng(2534),      :bhks(72784),     :brah(69734),     :cakm(69942),    :cham(43600),      :deva(2406),
        :diak(72016),     :fullwide(65296), :gong(73120),     :gonm(73040),    :gujr(2790),       :guru(2662),
        :hanidec(12295),  :hmng(93008),     :hmnp(123200),    :java(43472),    :kali(43264),      :kawi(73552),
        :khmr(6112),      :knda(3302),      :lana(6784),      :lanatham(6800), :laoo(3792),       :latn(48),
        :lepc(7232),      :limb(6470),      :mathbold(120782),:mathdbl(120792),:mathmono(120822), :mathsanb(120812),
        :mathsans(120802),:mlym(3430),      :modi(71248),     :mong(6160),     :mroo(92768),      :mtei(44016),
        :mymr(4160),      :mymrshan(4240),  :mymrtlng(43504), :nagm(124144),   :newa(70736),      :nkoo(1984),
        :olck(7248),      :orya(2918),      :osma(66720),     :rohg(68912),    :saur(43216),      :segment(130032),
        :shrd(70096),     :sind(70384),     :sinh(3558),      :sora(69872),    :sund(7088),       :takr(71360),
        :talu(6608),      :tamldec(3046),   :telu(3174),      :thai(3664),     :tibt(3872),       :tirh(70864),
        :tnsa(92864),     :vaii(42528),     :wara(71904),     :wcho(123632);
constant Plus = RakuAST::Infix.new('+');
constant Zero = RakuAST::IntLiteral.new(0);

proto sub rast-transliterate (|) is export {*}

multi sub rast-transliterate ($number-system, :$vanilla!) {
    # $result.ords.map(* + 49)>>.chr.join
    my $adjust = %digit-offset{$number-system} - 48; # 48 is '0' in ASCII/Unicode
    RakuAST::Sub.new( :scope<my>,
        name => RakuAST::Name.from-identifier('transliterate'),
        signature => RakuAST::Signature.new(
            parameters => RakuAST::Parameter.new(
                target => RakuAST::ParameterTarget::Var.new('$source'),
                traits => (RakuAST::Trait::Is.new( name => RakuAST::Name.from-identifier('raw')), )
        )   ),
        body => RakuAST::Blockoid.new( RakuAST::StatementList.new(
            RakuAST::Statement::Expression.new( expression =>
                RakuAST::ApplyPostfix.new( postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('join')),
                    operand => RakuAST::ApplyPostfix.new(
                        postfix => RakuAST::Call::Method.new(
                            name => RakuAST::Name.from-identifier('map'),
                            args => RakuAST::ArgList.new(
                                RakuAST::Block.new( body => RakuAST::Blockoid.new(
                                    RakuAST::StatementList.new(
                                        RakuAST::Statement::Expression.new(
                                            expression => RakuAST::ApplyPostfix.new(
                                                postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('chr')),
                                                operand => RakuAST::ApplyInfix.new( :infix(Plus),
                                                    left => RakuAST::Var::Lexical.new('$_'),
                                                    right => RakuAST::IntLiteral.new($adjust),
                        )   )   )), )   )   )   ),
                        operand => RakuAST::ApplyPostfix.new(
                            operand => RakuAST::Var::Lexical.new('$source'),
                            postfix => RakuAST::Call::Method.new(name => RakuAST::Name.from-identifier('ords'))
                        )))))))
}

# Creates a sub that transliterates a given string to a different decimal system
multi sub rast-transliterate($number-system, :$nqp!) {
    # This is currently the fastest (regardless of length) version I can come up with
    # It does require ALL codes to be in the convertable range.
    # The value passed into zero should indicate what the Unicode decimal zero is
    #
    # sub transliterate($source is raw) {
    #     my int32 @temp;
    #     nqp::strtocodes($source, nqp::const::NORMALIZE_NFC, @temp);
    #     my int32 i = nqp::elems(@temp);
    #     nqp::while(
    #         ($temp2 = nqp::sub_i($i,1)),
    #         {
    #             nqp::bindpos_i(
    #                 @temp, $i,
    #                 nqp::add_i(nqp::atpos_i(@temp,$i),$adj)
    #             )
    #         }
    #     )
    #     nqp::strfromcodes(@temp);
    # }
    return Empty if $number-system eq 'latn';
    my $adjust = %digit-offset{$number-system} - 48; # 48 is '0' in ASCII/Unicode
    use nqp;
    RakuAST::Statement::Expression.new( expression =>
        RakuAST::Sub.new(
            name => RakuAST::Name.from-identifier('transliterate'),
            signature => RakuAST::Signature.new(
                parameters =>  (
                    RakuAST::Parameter.new(
                        target =>  RakuAST::ParameterTarget::Var.new('$source'),
                        traits => (RakuAST::Trait::Is.new( name => RakuAST::Name.from-identifier('raw') ),)
            ),  )   ),
            body => blockoid-statement-list(
                RakuAST::Statement::Expression.new( expression =>
                    RakuAST::VarDeclaration::Simple.new(
                        name => '@temp',
                        type => RakuAST::Type::Simple.new( RakuAST::Name.from-identifier('int32') ),
                )   ),
                RakuAST::Statement::Expression.new( expression =>
                    RakuAST::Nqp.new(
                        'strtocodes',
                        RakuAST::Var::Lexical.new('$source'),
                        RakuAST::Nqp::Const.new('NORMALIZE_NFC'),
                        RakuAST::Var::Lexical.new('@temp'),
                )   ),
                RakuAST::Statement::Expression.new( expression =>
                    RakuAST::VarDeclaration::Simple.new(
                        name => '$i',
                        type => RakuAST::Type::Simple.new( RakuAST::Name.from-identifier('int32') ),
                        initializer => RakuAST::Initializer::Assign.new(
                            RakuAST::Nqp.new(
                                'elems',
                                RakuAST::Var::Lexical.new('@temp')
                )   )   )   ),
                RakuAST::Statement::Expression.new( expression =>
                    RakuAST::Nqp.new(
                        'while',
                        RakuAST::SemiList.new(
                            RakuAST::Statement::Expression.new( expression =>
                                RakuAST::ApplyInfix.new(
                                    left => RakuAST::Var::Lexical.new('$i'),
                                    infix => RakuAST::Infix.new('='),
                                    right => RakuAST::Nqp.new(
                                        'sub_i',
                                        RakuAST::Var::Lexical.new('$i'),
                                        RakuAST::IntLiteral.new(1),
                        )   )   )   ),
                        RakuAST::Nqp.new(
                            'bindpos_i',
                            RakuAST::Var::Lexical.new('@temp'),
                            RakuAST::Var::Lexical.new('$i'),
                            RakuAST::Nqp.new(
                                'add_i',
                                RakuAST::Nqp.new('atpos_i',RakuAST::Var::Lexical.new('@temp'),RakuAST::Var::Lexical.new('$i')),
                                RakuAST::IntLiteral.new($adjust), #RakuAST::Var::Lexical.new('$adj'),
                )   )   )   ),
                RakuAST::Statement::Expression.new( expression =>
                    RakuAST::Nqp.new(
                        'bindpos_i',
                        RakuAST::Var::Lexical.new('@temp'),
                        RakuAST::Var::Lexical.new('$i'),
                        RakuAST::Nqp.new(
                            'add_i',
                            RakuAST::Nqp.new('atpos_i',RakuAST::Var::Lexical.new('@temp'),Zero),
                            RakuAST::IntLiteral.new($adjust), #RakuAST::Var::Lexical.new('$adj'),
                )   )   ),
                RakuAST::Statement::Expression.new( expression =>
                    RakuAST::Call::Name.new(
                        name => RakuAST::Name.from-identifier('return'),
                        args => RakuAST::ArgList.new(RakuAST::Nqp.new('strfromcodes',RakuAST::Var::Lexical.new('@temp')))
    )   )   )   )   )
}
