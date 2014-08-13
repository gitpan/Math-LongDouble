use warnings;
use strict;
use Math::LongDouble qw(:all);

print "1..1\n";


if($Math::LongDouble::VERSION eq '0.05' && Math::LongDouble::_get_xs_version() eq $Math::LongDouble::VERSION) {print "ok 1\n"}
else {print "not ok 1 $Math::LongDouble::VERSION ", Math::LongDouble::_get_xs_version(), "\n"}

