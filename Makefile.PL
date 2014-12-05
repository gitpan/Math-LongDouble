use ExtUtils::MakeMaker;


eval {require ActivePerl::DocTools;};
unless($@) {
  warn "\n  WARNING: The sqrt and ** (pow) overloading is buggy\n",
       "           on ActivePerl. (See the README file.)\n\n";
}

###############################################

# Try to detect some common fatal linking errors ahead of time. If we detect
# that any of these linking problems exist, we then abort the Makefile.PL then
# and there. This doesn't do anything useful beyond avoiding cpan-tester FAIL reports.
# To avoid being subjected to the abort, just comment out line 34 below (which is "exit 0;")

my $cc;

if(@ARGV) {
  for my $arg(@ARGV) {
    $cc = (split /=/, $arg)[1] if $arg =~ /^cc=/i;
  }
}

unless(defined($cc)) {
  $cc = defined($Config{cc}) ? $Config{cc} : 'cc';
}

my $out = `$cc -o try.exe -x c try.in -lm 2>&1`;

print "output: $out\n";

# No linking problem at all if try.exe exists.
unless(-e 'try.exe') {
  if($out =~ /(`|'|"|\s)_?erfl('|`|"|\s)/) {
    print "Aborting:\n$out\n";
    exit 0; # abort the build
  }
}
# Remove the test executable
if(-e 'try.exe' && !unlink('./try.exe')) {
  warn "Failed to unlink try.exe";
}

###############################################

my $defines = $] < 5.008 ? "-DOLDPERL" : "-DNEWPERL";

###############################################
# Try to detect a nan bug that has nan**0 is nan.
# (Correct implementations have nan**0 == 1.)

$out = `$cc -o try2.exe -x c try2.in -lm 2>&1`;

sleep 1;

print "Build output:\n$out\n" unless -e try2.exe;

$diag = $^O =~ /mswin32/i ? `try2.exe 2>&1` : `./try2.exe 2>&1`;

print "diag: $diag\n" if defined $diag;

$defines .= ' -DNAN_POW_BUG' if $diag =~ /^NaN/i;

# Remove the second test executable
if(-e 'try2.exe' && !unlink('./try2.exe')) {
  warn "Failed to unlink try2.exe";
}

###############################################

$defines .= $Config::Config{byteorder} =~ /^1234/ ? " -DWE_HAVE_LENDIAN" : " -DWE_HAVE_BENDIAN";

$defines .= " -DLONGLONG2IV_IS_OK"
  if $Config::Config{ivsize} >= $Config::Config{longlongsize};

$defines .= " -DLONG2IV_IS_OK"
  if $Config::Config{ivsize} >= $Config::Config{longsize};

$defines .= ' -DMATH_LONGDOUBLE_DEBUG'
  if "@ARGV" =~ /DEBUG/;

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
