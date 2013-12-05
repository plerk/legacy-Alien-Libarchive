package Alien::Libarchive::ModuleBuild;

use strict;
use warnings;
use base qw( Alien::Base::ModuleBuild );

sub new
{
  my $class = shift;
  if($^O eq 'MSWin32')
  {
    return Module::Build->new(@_);
  }
  else
  {
    return $class->SUPER::new(@_);
  }
}

sub alien_do_commands
{
  my($self, $phase) = @_;

  local $ENV{CFLAGS} = $ENV{CFLAGS};
  local $ENV{LIBS}   = $ENV{LIBS};
  foreach my $name (qw( Alien::LibXML Alien::OpenSSL ))
  {
    my $alien = eval q{ require $name; $name->new };
    next if $@;
    print "using $name";
    $ENV{CFLAGS} .= ' ' . $alien->cflags;
    $ENV{LIBS}   .= ' ' . $alien->libs;
  }
  
  $self->SUPER::alien_do_commands($phase);
}

sub alien_check_installed_version {
  my($self) = @_;

  return if ($ENV{ALIEN_LIBARCHIVE}||'') eq 'share';

  if($^O eq 'freebsd' && -e "/usr/include/archive.h" && -e "/usr/include/archive_entry.h")
  {
    # bsdtar 2.8.4 - libarchive 2.8.4
    my $out = `bsdtar --version`;
    if($out =~ /- libarchive ([\d\.]+)$/)
    {
      print "found bsd system libarchive $1\n";
      return $1;
    }
  }

  return $self->SUPER::alien_check_installed_version;
}

package
  main;

sub alien_patch ()
{
  if($^O eq 'cygwin' && `pwd` =~ /libarchive-3.1.2/)
  {
    open my $in,  '<', 'libarchive/archive_crypto_private.h';
    open my $out, '>', 'libarchive/archive_crypto_private.h.tmp';
    while(<$in>)
    {
      if(/^#include \<wincrypt.h\>/)
      {
        print $out "#if defined(__CYGWIN__)\n";
        print $out "#include <windows.h>\n";
        print $out "#endif\n";
      }
      print $out $_;
    }
    close $in;
    close $out;
    unlink 'libarchive/archive_crypto_private.h';
    rename 'libarchive/archive_crypto_private.h.tmp', 'libarchive/archive_crypto_private.h';
  }
}

1;
