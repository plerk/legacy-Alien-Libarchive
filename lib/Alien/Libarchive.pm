package Alien::Libarchive;

use strict;
use warnings;

use base 'Alien::Base';

# ABSTRACT: Build and make available libarchive
# VERSION

=head1 SYNOPSIS

Build.PL

 use Alien::Libarchive;
 use Module::Build;
 
 my $alien = Alien::Libarchive->new;
 my $build = Module::Build->new(
   ...
   extra_compiler_flags => $alien->cflags,
   extra_linker_flags   => $alien->libs,
   ...
 );
 
 $build->create_build_script

=head1 DESCRIPTION

This distribution installs libarchive so that it can be used by other
Perl distributions.  If it can find the development package for libarchive
for your operating system it will use that, otherwise it will download
libarchive, build and install that.

=head1 METHODS

=head2 cflags

Returns the C compiler flags necessary to build against libarchive.

=head2 libs

Returns the library flags necessary to build against libarchive.

=head1 SEE ALSO

=over 4

=item L<Archive::Libarchive::XS>

=item L<Archive::Libarchive::FFI>

=back

=cut

# extract the macros from the header files, this is a private function
# because it may not be portable.  Used by Archive::Libarchive::XS
# (and maybe Archive::Libarchive::FFI) to automatically generate
# constants
# UPDATE: this maybe should use C::Scan or C::Scan::Constants
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
