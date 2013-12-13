package Alien::Libarchive::ModuleBuild;

use strict;
use warnings;
use base qw( Alien::Base::ModuleBuild );
use FindBin ();

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

my $cflags = '';
my $libs   = '';
  
sub alien_do_commands
{
  my($self, $phase) = @_;

  unless($cflags)
  {
    my $first = 1;
    foreach my $name (qw( Alien::LibXML Alien::OpenSSL Alien::bz2 ))
    {
      my $alien = eval qq{ require $name; $name->new };
      next if $@;
      print "\n\n" if $first; $first = 0;
      print "  trying to use $name\n";
      $cflags .= ' ' . $alien->cflags;
      $libs   .= ' ' . $alien->libs;
    }
    print "\n\n" unless $first;
  }

  local $ENV{CFLAGS} = $cflags;
  local $ENV{LIBS}   = $libs;
  
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

sub alien_interpolate
{
  my($self, $string) = @_;
  $string =~ s/(?<!\%)\%d/$FindBin::Bin/eg;
  $self->SUPER::alien_interpolate($string);
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
