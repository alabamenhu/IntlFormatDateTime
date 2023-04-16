use v6.d;
unit module ExemplarCities;

sub exemplar-city($language,$datetime) is export {
    use Intl::CLDR;
    cldr{$language}.dates.timezone-names.zones{$datetime.olson-id}.?exemplar-city
}
#// $^tz.zones<Etc/Unknown>.exemplar-city },
