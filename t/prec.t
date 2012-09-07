use warnings;
use strict;
use Math::LongDouble qw(:all);

my $tests = 7;
print "1..$tests\n";

my $tv = STRtoLD('-1e-37');

if(ld_get_prec() == 18) {print "ok 1\n"}
else {
  warn "\nDefault precision: ", ld_get_prec(), "\n";
  print "not ok 1\n";
}

my $man = (split /e/i, LDtoSTR($tv))[0];

if($man eq '-1.00000000000000000') {print "ok 2\n"}
else {
  warn "\n2: Got: $man\n";
  print "not ok 2\n";
}

$man = (split /e/i, LDtoSTRP($tv, 19))[0];

if($man eq '-9.999999999999999999') {print "ok 3\n"}
else {
  warn "\n3: Got: $man\n";
  print "not ok 3\n";
}

ld_set_prec(19);

if(ld_get_prec() == 19) {print "ok 4\n"}
else {
  warn "\nDefault Precision: ", ld_get_prec(), "\n";
  print "not ok 4\n";
}

$tv *= UnityLD(-1);

my $len = length((split /e/i, $tv)[0]);

if($len == 20) {print "ok 5\n"} # 19 digits plus decimal point
else {
  warn "\nLength: $len\n";
  print "not ok 5\n";
}

eval{ld_set_prec(-2);};
if($@ =~ /1st arg/){print "ok 6\n"}
else {
  warn "\$\@: $@";
  print "not ok 6\n";
}

eval{LDtoSTRP($tv, 0);};
if($@ =~ /2nd arg/){print "ok 7\n"}
else {
  warn "\$\@: $@";
  print "not ok 7\n";
}

