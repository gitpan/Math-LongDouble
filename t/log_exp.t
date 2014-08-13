use warnings;
use strict;
use Math::LongDouble qw(:all);
use Config;

print "1..7\n";

my $n = 1.3;
my $nld = Math::LongDouble->new(1.3);

my $exp = exp($n);
my $exp_ld = exp($nld);
my $log_ld = log($exp_ld);
my $two = Math::LongDouble->new(2.0);
my $log = log($two);

if(approx($exp_ld, $exp)) {print "ok 1\n"}
else {
  warn "\n\$exp_ld: $exp_ld\n\$exp: $exp\n";
  print "not ok 1\n";
}

if(approx($log_ld, $n)) {print "ok 2\n"}
else {
  warn "\n\$log_ld: $log_ld\n\$n: $n\n";
  print "not ok 2\n";
}

if(is_InfLD(log(ZeroLD(1)))) {print "ok 3\n"}
else {
  warn "\nlog(0): ", log(ZeroLD(1)), "\n";
  print "not ok 3\n";
}

if(is_NaNLD(log(UnityLD(-1)))) {print "ok 4\n"}
else {
  warn "\nlog(-1): ", log(UnityLD(-1)), "\n";
  print "not ok 4\n";
}

if(Math::LongDouble::_long_double_size() != $Config{nvsize}) {
  if(cmp_NV($log, log(2.0))) {print "ok 5\n"}
  else {
    warn "\n\$log: ", log($two), "\nlog(2.0): ", log(2.0), "\n";
    print "not ok 5\n";
  }
}
else {
  unless(cmp_NV($log, log(2.0))) {print "ok 5\n"}
  else {
    warn "\n\$log: ", log($two), "\nlog(2.0): ", log(2.0), "\n";
    print "not ok 5\n";
  }
}

if(approx($log, Math::LongDouble->new('6.9314718055994530943e-001'))) {print "ok 6\n"}
else {
  warn "\n\$log: $log\n";
  print "not ok 6\n";
}

if(Math::LongDouble::_long_double_size() != $Config{nvsize}) {
  if(cmp_NV($exp_ld, $exp)) {print "ok 7\n"}
  else {
    warn "\n\$exp_ld: $exp_ld\n\$exp: $exp\n";
    print "not ok 7\n";
  }
}
else {
  unless(cmp_NV($exp_ld, $exp)) {print "ok 7\n"}
  else {
    warn "\n\$exp_ld: $exp_ld\n\$exp: $exp\n";
    print "not ok 7\n";
  }
}

sub approx {
    my $eps = abs($_[0] - Math::LongDouble->new($_[1]));
    return 0 if $eps > Math::LongDouble->new(0.000000001);
    return 1;
}
