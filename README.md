# Alien::Libarchive

Build and make available libarchive

# SYNOPSIS

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

# DESCRIPTION

This distribution installs libarchive so that it can be used by other
Perl distributions.  If already installed for your operating system, and
if it can find it, this distribution will use the libarchive that comes
with your operating system, otherwise it will download it from the 
Internet, build and install it.

If you set the environment variable ALIEN\_LIBARCHIVE to 'share', this
distribution will ignore any system libarchive found, and build from
source instead.  This may be desirable if your operating system comes
with a very old version of libarchive and an upgrade path for the 
system libarchive is not possible.

## Requirements

### operating system install

The development headers and libraries for libarchive

On Debian you can install these with this command:

    % sudo apt-get install libarchive-dev

On Cygwin, make sure that this package is installed

    libarchive-devel

libarchive comes with FreeBSD as of version 5.3.

### from source install

A C compiler and any prerequisites for building libarchive.

# METHODS

## cflags

Returns the C compiler flags necessary to build against libarchive.

## libs

Returns the library flags necessary to build against libarchive.

# CAVEATS

Native windows support is completely missing at the moment.  It is 
possible to install using the "operating system install" if you have the 
package `libarchive-devel` installed (you should be able to find it 
with `setup.exe`.  Doing a "from source install" does not work as of
this writing.  Debian Linux and FreeBSD (9.0) have been tested the most
in development of this distribution.

Patches to improve portability and platform support would be eagerly
appreciated.

If you reinstall this distribution, you may need to reinstall any
distributions that depend on it as well.

# SEE ALSO

- [Archive::Libarchive::XS](https://metacpan.org/pod/Archive::Libarchive::XS)
- [Archive::Libarchive::FFI](https://metacpan.org/pod/Archive::Libarchive::FFI)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
