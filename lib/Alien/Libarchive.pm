package Alien::Libarchive;

use strict;
use warnings;

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

B<NOTE>: This version of Alien::Libarchive has been deprecated in favor
of a re-write which is hosted here:

=over 4

=item L<https://github.com/plicease/Alien-Libarchive2>

=back

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

=over 4

=item Debian

On Debian you can install these with this command:

 % sudo apt-get install libarchive-dev

=item Cygwin

On Cygwin, make sure that this package is installed

 libarchive-devel

=item FreeBSD

libarchive comes with FreeBSD as of version 5.3.

=back

=head3 from source install

A C compiler and any prerequisites for building libarchive.

=over 4

=item Debian

On Debian build-essential should be good enough:

 % sudo apt-get install build-essential

=item Cygwin

On Cygwin, I couldn't get libarchive to build without making a
minor tweak to one of the include files.  On Cygwin this module
will patch libarchive before it attempts to build if it is
version 3.1.2.

=item Strawberry Perl

For MinGW based Perls (including Strawberry), this module will
delegate to L<Alien::Libarchive::MSWin32>.  The reason for not
supporting MinGW directly in this distribution is because it
requires CMake at configure time, and I don't want to make
that a prereq everywhere.

Probably the easiest way to get this to work is to install
CMake binaries from their website,

=over 4

=item L<http://www.cmake.org/cmake/resources/software.html>

=back

And then install L<Alien::CMake>.

=back

=head1 METHODS

=head2 cflags

Returns the C compiler flags necessary to build against libarchive.

=head2 libs

Returns the library flags necessary to build against libarchive.

=head1 CAVEATS

Debian Linux and FreeBSD (9.0) have been tested the most
in development of this distribution.

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

if($^O eq 'MSWin32')
{
  eval q{ use Alien::Libarchive::MSWin32 };
  die $@ if $@;
  foreach my $subname (qw( new libs cflags ))
  {
    eval qq{ sub $subname { shift; Alien::Libarchive::MSWin32->$subname(\@_) } };
    die $@ if $@;
  }
}
else
{
  require Alien::Libarchive::Unix;
}

1;
