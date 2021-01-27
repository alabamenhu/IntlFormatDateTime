#!/usr/bin/env perl6

use Intl::Format::DateTime;
use DateTime::Timezones;

my $d1 = DateTime.new: :2020year, :1month, :2day, :3hour, :4minute, :5second;

sink format-datetime $d1;
my @a; my $a;
my @b; my $b;
my $time;


$time = now;
@a.push: format-datetime $d1 for ^100;
$a = now - $time;

$time = now;
@b.push: $d1.Str for ^100;
$b = now - $time;

say $a;
say $b;