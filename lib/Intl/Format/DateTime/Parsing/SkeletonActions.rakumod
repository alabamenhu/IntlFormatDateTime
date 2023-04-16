use v6.d;
unit class SkeletonActions;

use Intl::Format::DateTime::Parsing::Classes;

# Make the full combination
method TOP ($/) {
    make $<element>.map(*.made).flat
}

# For a literal, generate the text
method element:sym<literal> ($/) { make $<text>.map(*.made).flat                          }
method text:sym<apostrophe> ($/) { make StringLiteral.new(text => "'")                    }
method text:sym<literal>    ($/) { make StringLiteral.new(text => $/.Str)                 }
method text:sym<quoted>     ($/) { make StringLiteral.new(text => $/.Str.subst("''","'")) }

###########################################################################################
use Intl::Format::DateTime::Formatters::a-lc; use Intl::Format::DateTime::Formatters::A-uc;
use Intl::Format::DateTime::Formatters::b-lc; use Intl::Format::DateTime::Formatters::B-uc;
use Intl::Format::DateTime::Formatters::c-lc; #`[   there  is  no  cldr  'C'  formatter   ]
use Intl::Format::DateTime::Formatters::d-lc; use Intl::Format::DateTime::Formatters::D-uc;
use Intl::Format::DateTime::Formatters::e-lc; use Intl::Format::DateTime::Formatters::E-uc;
#`[   there  is  no  cldr  'f'  formatter   ] use Intl::Format::DateTime::Formatters::F-uc;
use Intl::Format::DateTime::Formatters::g-lc; use Intl::Format::DateTime::Formatters::G-uc;
use Intl::Format::DateTime::Formatters::h-lc; use Intl::Format::DateTime::Formatters::H-uc;
#`[   there  is  no  cldr  'i'  formatter   ] #`[   there  is  no  cldr  'I'  formatter   ]
#`[   there  is  no  cldr  'j'  formatter   ] #`[   there  is  no  cldr  'J'  formatter   ]
use Intl::Format::DateTime::Formatters::k-lc; use Intl::Format::DateTime::Formatters::K-uc;
use Intl::Format::DateTime::Formatters::l-lc; use Intl::Format::DateTime::Formatters::L-uc;
use Intl::Format::DateTime::Formatters::m-lc; use Intl::Format::DateTime::Formatters::M-uc;
#`[   there  is  no  cldr  'n'  formatter   ] #`[   there  is  no  cldr  'N'  formatter   ]
#`[   there  is  no  cldr  'o'  formatter   ] use Intl::Format::DateTime::Formatters::O-uc;
#`[   there  is  no  cldr  'p'  formatter   ] #`[   there  is  no  cldr  'P'  formatter   ]
use Intl::Format::DateTime::Formatters::q-lc; use Intl::Format::DateTime::Formatters::Q-uc;
use Intl::Format::DateTime::Formatters::r-lc; #`[   there  is  no  cldr  'R'  formatter   ]
use Intl::Format::DateTime::Formatters::s-lc; use Intl::Format::DateTime::Formatters::S-uc;
#`[   there  is  no  cldr  't'  formatter   ] #`[   there  is  no  cldr  'T'  formatter   ]
use Intl::Format::DateTime::Formatters::u-lc; use Intl::Format::DateTime::Formatters::U-uc;
use Intl::Format::DateTime::Formatters::v-lc; use Intl::Format::DateTime::Formatters::V-uc;
use Intl::Format::DateTime::Formatters::w-lc; use Intl::Format::DateTime::Formatters::W-uc;
use Intl::Format::DateTime::Formatters::x-lc; use Intl::Format::DateTime::Formatters::X-uc;
use Intl::Format::DateTime::Formatters::y-lc; use Intl::Format::DateTime::Formatters::Y-uc;
use Intl::Format::DateTime::Formatters::z-lc; use Intl::Format::DateTime::Formatters::Z-uc;
###########################################################################################
constant formatters = &format-A, &format-B, Nil, &format-D, &format-E, &format-F, &format-G,
&format-H, Nil, Nil, &format-K, &format-L, &format-M, Nil, &format-O, Nil,  &format-Q, Nil, &format-S, Nil,
&format-U, &format-V, &format-W, &format-X, &format-Y, &format-Z, Nil, Nil, Nil, Nil, Nil,
Nil, &format-a, &format-b, &format-c, &format-d, &format-e, Nil, &format-g, &format-h, Nil,
Nil, &format-k, &format-l, &format-m, Nil, Nil, Nil, &format-q, &format-r, &format-s, Nil,
&format-u, &format-v, &format-w, &format-x, &format-y, &format-z;

method element:sym<replace> ($/) {
    my $letter := $/.Str.substr.ord - 65;
    make SkeletonReplacement.new(
        sub => formatters[$letter],
        length => $/.chars,
        type => $/.Str.substr(0,1),
    )
}