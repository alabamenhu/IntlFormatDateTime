use v6.d;
unit module Classes;

role PatternElement is export {
    method generate-code($block) { ... }
}

class Replacement does PatternElement is export {
    has &.sub;
    has $.length;
    method generate-code(\data) { &!sub($!length,data) }
}

class SkeletonReplacement does PatternElement is export {
    has &.sub;
    has $.length;
    has $.type;
    proto method generate-code(|c)              { * }
    multi method generate-code(\data)           { &!sub($!length,data) }
    multi method generate-code(\data,\skeleton) { &!sub( (skeleton{$!type} // $!length),data) }
}

class StringLiteral does PatternElement is export {
    has $.text;
    method generate-code(\data, $?) {
        use Intl::Format::DateTime::Util;
        use experimental :rakuast;
        concat-to-result-stmt RakuAST::StrLiteral.new($!text)
    }
}
