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
    
    ffi_lib \$_ for DynaLoader::dl_findfile(split /\s+/, Alien::Libarchive->new->libs);

# DESCRIPTION

This distribution installs libarchive so that it can be used by other
Perl distributions.  If already installed for your operating system, and
if it can find it, this distribution will use the libarchive that comes
with your operating system, otherwise it will download it from the 
Internet, build and install it.

## Requirements

### operating system install

The development headers and libraries for libarchive

On Debian you can install these with this command:

    % sudo apt-get install libarchive-dev

### from source install

A C compiler and any prerequisites for building libarchive.

# METHODS

## cflags

Returns the C compiler flags necessary to build against libarchive.

## libs

Returns the library flags necessary to build against libarchive.

# SEE ALSO

- [Archive::Libarchive::XS](https://metacpan.org/pod/Archive::Libarchive::XS)
- [Archive::Libarchive::FFI](https://metacpan.org/pod/Archive::Libarchive::FFI)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
