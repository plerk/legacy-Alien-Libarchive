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

1;
