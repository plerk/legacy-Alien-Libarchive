package Alien::Libarchive::ModuleBuild;

use strict;
use warnings;
## use Alien::LibXML;
## use Alien::OpenSSL;
use base qw( Alien::Base::ModuleBuild );

sub alien_do_commands
{
  my($self, $phase) = @_;

##   local $ENV{CFLAGS} = $ENV{CFLAGS};
##   local $ENV{LIBS}   = $ENV{LIBS};
##   foreach my $alien (map { $_->new } qw( Alien::LibXML Alien::OpenSSL ))
##   {
##     $ENV{CFLAGS} .= ' ' . $alien->cflags;
##     $ENV{LIBS}   .= ' ' . $alien->libs;
##   }
##   
##   #print "\n\nCFLAGS = $ENV{CFLAGS}\n";
##   #print "LIBS   = $ENV{LIBS}\n\n\n";
  
  $self->SUPER::alien_do_commands($phase);
}

sub alien_check_installed_version {
  my($self) = @_;

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
