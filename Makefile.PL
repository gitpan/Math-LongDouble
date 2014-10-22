use ExtUtils::MakeMaker;

eval {require ActivePerl::DocTools;};
unless($@) {
  warn "\n  WARNING: The sqrt and ** (pow) overloading is buggy\n",
       "           on ActivePerl. (See the README file.)\n\n";
}

my $defines = $] < 5.008 ? "-DOLDPERL" : "-DNEWPERL";

my %options = %{
{
  NAME => 'Math::LongDouble',
  LIBS => [
    '-lm'
  ],
  INC => '',
  LICENSE  => 'perl',
  VERSION_FROM => 'LongDouble.pm',
  DEFINE   => $defines,
  META_MERGE => {
   'meta-spec' => { version => 2 },
    resources => {
      repository => {
        type => 'git',
        url => 'https://github.com/sisyphus/math-longdouble.git',
        web => 'https://github.com/sisyphus/math-longdouble',
      },
    },
  },
}
};
WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }
