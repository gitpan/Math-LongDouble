use warnings;
use strict;
use Math::LongDouble qw(:all);

print "1..9\n";

my $n = Math::LongDouble->new('3.5');
my $unity = UnityLD(1);
my $two = Math::LongDouble::UVtoLD(2);

if(-$unity == UnityLD(-1)) {print "ok 1\n"}
else {print "not ok 1\n"}

$n = $n + $unity;
if($n == Math::LongDouble->new('4.5')){print "ok 2\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 2\n";
}

$n = $n - $unity;
if($n == Math::LongDouble->new('3.5')){print "ok 3\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 3\n";
}

$n = $n * $two;
if($n == Math::LongDouble->new('7')){print "ok 4\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 4\n";
}

$n = $n / $two;
if($n == Math::LongDouble->new('3.5')){print "ok 5\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 5\n";
}

$n += $unity;
if($n == Math::LongDouble->new('4.5')){print "ok 6\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 6\n";
}

$n -= $unity;
if($n == Math::LongDouble->new('3.5')){print "ok 7\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 7\n";
}

$n *= $two;
if($n == Math::LongDouble->new('7')){print "ok 8\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 8\n";
}

$n /= $two;
if($n == Math::LongDouble->new('3.5')){print "ok 9\n"}
else {
  warn "\n\$n: $n\n";
  print "not ok 9\n";
}