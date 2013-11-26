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

Makefile.PL

 use Alien::Libarchive;
 use ExtUtils::MakeMaker;
 
 my $alien = Alien::Libarchive->new;
 WriteMakefile(
   ...
   CFLAGS => Alien::Libarchive->cflags,
   LIBS   => Alien::Libarchive->libs,
 );

FFI

 use Alien::Libarchive;
 use FFI::Sweet qw( ffi_lib );
 
 ffi_lib(Alien::Libarchive->new->libs);

=head1 DESCRIPTION

This distribution installs libarchive so that it can be used by other
Perl distributions.  If already installed for your operating system, and
if it can find it, this distribution will use the libarchive that comes
with your operating system, otherwise it will download it from the 
Internet, build and install it.

If you set the environment variable ALIEN_LIBARCHIVE to 'share', this
distribution will ignore any system libarchive found, and build from
source instead.  This may be desirable if your operating system comes
with a very old version of libarchive and an upgrade path for the 
system libarchive is not possible.

=head2 Requirements

=head3 operating system install

The development headers and libraries for libarchive

On Debian you can install these with this command:

 % sudo apt-get install libarchive-dev

libarchive comes with FreeBSD as of version 5.3.

=head3 from source install

A C compiler and any prerequisites for building libarchive.

=head1 METHODS

=head2 cflags

Returns the C compiler flags necessary to build against libarchive.

=head2 libs

Returns the library flags necessary to build against libarchive.

=head1 CAVEATS

Native windows support is completely missing at the moment.  It should
in theory be possible to install in a cygwin environment.  However, I
just tried it and it did not work.  Debian Linux and FreeBSD (9.0) have
been tested in development of this distribution.

Patches to improve portability and platform support would be eagerly
appreciated.

If you reinstall this distribution, you may need to reinstall any
distributions that depend on it as well.

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

sub libs
{
  my($self) = @_;
  if($self->install_type eq 'system' && $^O eq 'freebsd' && -e "/usr/include/archive.h" && -e "/usr/include/archive_entry.h")
  {
    return '-larchive';
  }
  else
  {
    return $self->SUPER::libs;
  }
}

sub cflags
{
  my($self) = @_;
  if($self->install_type eq 'system' && $^O eq 'freebsd' && -e "/usr/include/archive.h" && -e "/usr/include/archive_entry.h")
  {
    return '';
  }
  else
  {
    return $self->SUPER::cflags;
  }
}

1;
