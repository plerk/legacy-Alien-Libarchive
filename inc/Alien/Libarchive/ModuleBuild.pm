package Alien::Libarchive::ModuleBuild;

use strict;
use warnings;
use base qw( Alien::Base::ModuleBuild );

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

  return if ($ENV{ALIEN_LIBARCHIVE}//'') eq 'share';

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

1;
