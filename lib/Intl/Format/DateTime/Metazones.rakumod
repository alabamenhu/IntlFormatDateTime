use v6.d;

my %tz-meta := BEGIN do {
    my %tz-meta;
    for %?RESOURCES<metazones.data>.lines {
        constant DELIMITER = ',';
        my @elements = .split(DELIMITER);
        my $tz = @elements.shift;
        my @forms;
        while @elements {
            @forms.push(List.new(.shift, .shift.Int, .shift.Int)) with @elements;
        }
        %tz-meta{$tz} := @forms;
    }
    %tz-meta
}

my sub meta-tz(DateTime $dt) is export {
   CATCH {die "In order to format using a timezone name, you must load DateTime::Timezones";}
   my $olson = $dt.olson-id;
   with %tz-meta{$olson} -> @meta-list {
       my $posix = $dt.posix;
       for @meta-list -> ($name, $start, $end) {
           return $name if $start ≤ $posix < $end;
       }
   }
   Nil # Kick back a Nil to allow for a fallback formatter
}

sub EXPORT {
    Map.new:
        '&meta-tz' => &meta-tz,
}