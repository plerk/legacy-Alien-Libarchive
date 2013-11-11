package Alien::Libarchive;

use strict;
use warnings;

use base 'Alien::Base';

# ABSTRACT: Build and make available libarchive
# VERSION

# extract the macros from the header files, this is a private function
# because it may not be portable.  Used by Archive::Libarchive::XS
# (and maybe Archive::Libarchive::FFI) to automatically generate
# constants
sub _macro_list
{
  require Config;
  require File::Temp;
  require File::Spec;

  my $alien = Alien::Libarchive->new;  
  my $cc = "$Config::Config{ccname} $Config::Config{ccflags} " . $alien->cflags;
  
  my $fn = File::Spec->catfile(File::Temp::tempdir( CLEANUP => 1 ), "test.c");
  
  do {
    open my $fh, '>', $fn;
    print $fh "#include <archive.h>\n";
    print $fh "#include <archive_entry.h>\n";
    close $fh;
  };
  
  my @list;
  my $cmd = "$cc -E -dM $fn";
  foreach my $line (`$cmd`)
  {
    if($line =~ /^#define ((AE|ARCHIVE)_\S+)/)
    {
      push @list, $1;
    }
  }
  sort @list;
}

1;
