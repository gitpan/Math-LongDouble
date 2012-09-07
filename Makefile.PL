use ExtUtils::MakeMaker;

eval {require ActivePerl::DocTools;};
unless($@) {
  warn "\n  WARNING: The sqrt and ** (pow) overloading is buggy\n",
       "           on ActivePerl. (See the README file.)\n\n";
}

my %options = %{
{
  'NAME' => 'Math::LongDouble',
  'LIBS' => [
    '-lm'
  ],
  'INC' => '',
  'VERSION_FROM' => 'LongDouble.pm'
}
};
WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
