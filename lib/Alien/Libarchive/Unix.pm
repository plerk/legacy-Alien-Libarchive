package Alien::Libarchive::Unix;

package
  Alien::Libarchive;

use strict;
use warnings;
use Text::ParseWords qw( shellwords );
use base 'Alien::Base';
use File::ShareDir ();
use File::Spec;

# ABSTRACT: Build and make available libarchive (machinery for Unix)
# VERSION

=head1 SEE ALSO

=over 4

=item L<Alien::Libarchive>

=item L<Alien::Libarchive::MSWin32>

=back

=cut

# workaround for Alien::Base gh#30
sub import
{
  my $class = shift;
  
  if($class->install_type('share'))
  {
    unshift @DynaLoader::dl_library_path, 
      grep { s/^-L// } 
      shellwords( $class->libs );
    
    if($^O eq 'cygwin')
    {
      foreach my $dir (map { File::Spec->catdir($class->dist_dir, $_) } qw( .libs bin ))
      {
        $ENV{PATH} = join(':', $dir, $ENV{PATH}) if -d $dir;
      }
    }

  }
  
  $class->SUPER::import(@_);
}

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
