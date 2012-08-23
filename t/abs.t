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

if(abs($nunity) == $unity) {print "ok 1\n"}
else {
  warn "abs(\$nunity): ", abs($nunity), "\n\$unity: $unity\n";
  print "not ok 1\n";
}

if(abs($ninf) == $inf) {print "ok 2\n"}
else {
  warn "abs(\$ninf): ", abs($ninf), "\n\$inf: $inf\n";
  print "not ok 2\n";
}

if(abs($nzero) == $zero) {print "ok 3\n"}
else {
  warn "abs(\$nzero): ", abs($nzero), "\n\$zero: $zero\n";
  print "not ok 3\n";
}

if(is_ZeroLD(abs($nzero)) <= 0) {print "not ok 4\n"}
else {print "ok 4\n"}

if(is_NaNLD(abs($nnan))) {print "ok 5\n"}
else {print "not ok 5\n"}

if(is_NaNLD(abs($nan))) {print "ok 6\n"}
else {print "not ok 6\n"}