use v6.d;
unit module Skeletons;

class SkeletonPatternDatum {
    has Str $.symbol;
    has int $.distance;
}

sub best-pattern(\skeleton, \calendar) is export {
    my Str    $best       = '';
    my uint64 $best-score = 0xffffffff;
    my        $want       = skeleton-pattern-data skeleton;

    # Available formats is a set of pre-determined patterns that
    # are considered good / acceptable to use for the language.
    # Hash::keys is a temporary work around for a bug in Intl::CLDR
    for calendar.datetime-formats.available-formats.Hash::keys {
        # The difference is decided by a set of values per
        my $difference = skeleton-pattern-difference($want, skeleton-pattern-data $_);
        if $difference < $best-score {
            $best       = $_;
            $best-score = $difference
        }
    }
    calendar.datetime-formats.available-formats{$best};
}

# This assumes no non-pattern letters.
# That is an assumption that may not hold and should be fixed down the road.
sub skeleton-pattern-data($string) is export {
    state %cache;
    .return with %cache{$string};

    my @result  = Any xx 64;

    for $string.comb(/<[GyYuUrQqMLlwWdDfgEecabBhHKkjJCmsSAzZOvVXx]>/).join.match(/((.) $0*)/, :g) {
        use Intl::Format::DateTime::Constants;
        use Intl::Format::DateTime::FieldMeta;
        my $meta = %fields{.Str.substr(0,1)};

        @result[$meta.type * 2] = .Str;
        @result[$meta.type * 2 + 1] = $meta.distance;
    }
    %cache{$string} =
        do for @result -> $symbol, $distance {
            SkeletonPatternDatum.new: :symbol($symbol // ''), :distance($distance // 0);
        }
}

sub skeleton-pattern-replace-data($string) is export {
    state %cache;
    .return with %cache{$string};

    my %result;

    for $string.comb(/<[GyYuUrQqMLlwWdDfgEecabBhHKkjJCmsSAzZOvVXx]>/).join.match(/((.) $0*)/, :g) {
        %result{.substr(0,1)} := .Str.chars;
    }
    %cache{$string} = %result;
}


#| Calculates how different two skeleton patterns are (smaller is more similar)
sub skeleton-pattern-difference(\a, \b --> int) {
    use Intl::Format::DateTime::Constants;
    my int $difference = 0;
    for a<> Z b<> -> ($a, $b) {
        if    $a.distance == 0 && $b.distance != 0 { $difference += EXTRA   }
        elsif $a.distance != 0 && $b.distance == 0 { $difference += MISSING }
        else                 { $difference += abs $a.distance - $b.distance }
    }
    $difference
}