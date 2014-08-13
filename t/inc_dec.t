use warnings;
use strict;
use Math::LongDouble qw(:all);

print "1..2\n";

my $ld = NVtoLD(2.5);
my $ld_copy = $ld;

$ld++;

if($ld == NVtoLD(3.5)) {print "ok 1\n"}
else {
  warn "\n\$ld: $ld\n";
  print "not ok 1\n";
}

$ld--;

if($ld == $ld_copy) {print "ok 2\n"}
else {
  warn "\n\$ld: $ld\n";
  print "not ok 2\n";
}
