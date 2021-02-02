#!/usr/bin/env perl6

=begin pod
The point of this performance test is mainly to compare formatting times when
cache is and isn't available.  The comparison to core is more for curiosity,

As of v0.1 (Jan 2021), the normalized average of multiple sequential runs on short shows the following:
   NoCache : Cache : Core
     3689  :   20  :  1
=end pod


use Intl::Format::DateTime;
use DateTime::Timezones;

my @stats = "";
my @foo;
my $datetime = DateTime.new(now, :timezone<America/New_York>);
my $time;
my $length = 'full';   # other options include 'long', 'short'
                       # 'full'   uses the most data
                       # 'long'   forces timezone data to be used
                       # 'medium' is most commonly used
                       # 'short'  mirrors core the closest


# The initial test requires loading CLDR for each of the given languages
$time = now;
for <en ar nl ru zh ast ko el he hi ka am hy nl my chr> -> $language {
    @foo.push: format-datetime $datetime, :$language, :$length
}
@stats.push: "Without cache took { now - $time }";

.say for @foo;
@foo = ();

# The data is already loaded now, so look ups should be much faster
$time = now;
for <en ar nl ru zh ast ko el> -> $language {
    @foo.push: format-datetime($datetime, :$language, :$length)
}
@stats.push: "With cache took { now - $time }";

.say for @foo;
@foo = ();

# And for reference, the core date time
$time = now;
for <en ar nl ru zh ast ko el> -> $language {
    @foo.push: $datetime
}
@stats.push: "Core DateTime took { now - $time}";

.say for @foo;
@foo = ();

$time = now;
for <en ar nl ru zh ast ko el> -> $language {
    @foo.push: format-datetime $datetime, :$language, :$length
}
@stats.push: "With cache took { now - $time }";

.say for @foo;

.say for @stats;