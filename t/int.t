use warnings;
use strict;
use Math::LongDouble qw(:all);

print "1..6\n";

my $nan = NaNLD(1);
my $nnan = NaNLD(-1);
my $zero = ZeroLD(1);
my $nzero = ZeroLD(-1);
my $unity = UnityLD(1);
my $nunity = UnityLD(-1);
my $inf = InfLD(1);
my $ninf = InfLD(-1);

if(is_NaNLD(int($nan)) && is_NaNLD(int($nnan))) {print "ok 1\n"}
else {print "not ok 1\n"}

if(is_ZeroLD(int($zero)) && is_ZeroLD(int($nzero))) {print "ok 2\n"}
else {
  warn "int(\$zero): ", int($zero), "\nint(\$nzero): ", int($nzero), "\n";
  print "not ok 2\n";
}

if(is_InfLD(int($inf)) && is_InfLD(int($ninf))) {print "ok 3\n"}
else {print "not ok 3\n"}

if(int($unity) == UnityLD(1) && int($nunity) == UnityLD(-1)) {print "ok 4\n"}
else {print "not ok 4\n"}

my $nv = 1.6253;

if(int(NVtoLD($nv)) == UnityLD(1) &&
   int(NVtoLD($nv * -1.0)) == UnityLD(-1)) {print "ok 5\n"}
else {
  warn "int(NVtoLD(\$nv)): ",int(NVtoLD($nv)), "\n";
  print "not ok 5\n";
}

$nv = 0.6257;

if(is_ZeroLD(int(NVtoLD($nv))) > 0 &&
   is_ZeroLD(int(NVtoLD($nv * -1.0))) < 0) {print "ok 6\n"}
else {
  warn "int(NVtoLD(\$nv)): ", int(NVtoLD($nv)), "\n";
  warn "int(NVtoLD(\$nv * -1.0)): ", int(NVtoLD($nv * -1.0)), "\n";
  print "not ok 6\n";
}

