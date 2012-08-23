use ExtUtils::MakeMaker;

eval {require ActivePerl::DocTools;};
unless($@) {
  warn "\n  WARNING: The sqrt and ** (pow) overloading is buggy\n",
       "           on ActivePerl. (See the README file.)\n\n";
}

# It is assumed that the 'long double' has precision p = 64-bits (up to 20 decimal digits) of precision.
# If this is not the case, you can either:
#   1) Specify (below) '$digits = x;'
#  or
#   2) Run 'perl Makefile DIG=x'
# where x is ceil(p * 0.30103)

$digits = 0;

for(@ARGV) {
  if($_ =~ /DIG=/) {
    $digits = (split /=/, $_)[1];
  }
}

if ($digits > 0) {$defines = "-DLONG_DOUBLE_DECIMAL_PRECISION=$digits"}
else { # $digits is deemed to be 20 (and LONG_DOUBLE_DECIMAL_PRECISION is defined as 20).
  warn "\nAssuming 'long double' has 64 bits (20 decimal digits) of precision\n",
       "If this is wrong, see the README\n\n";
} 

my %options = %{
{
  'NAME' => 'Math::LongDouble',
  'LIBS' => [
    '-lm'
  ],
  'DEFINE' => $defines,
  'INC' => '',
  'VERSION_FROM' => 'LongDouble.pm'
}
};
WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
