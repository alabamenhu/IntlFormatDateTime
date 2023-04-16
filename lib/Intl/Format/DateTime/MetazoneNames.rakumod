use v6.d;
unit module MetazoneNames;
use Intl::Format::DateTime::Metazones;
use Intl::CLDR;

sub metazone-name($language,$datetime,$is-long,$generic) is export {
    my \base = cldr{$language}.dates.timezone-names.metazones{meta-tz $datetime};
    $generic
        ?? $is-long
            ?? base.?long .generic
            !! base.?short.generic
        !! $is-long
            ?? base.?long{ $datetime.is-dst ?? 'daylight' !! 'standard'}
            !! base.?short{$datetime.is-dst ?? 'daylight' !! 'standard'}
}
