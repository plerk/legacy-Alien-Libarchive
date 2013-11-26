use strict;
use warnings;
use Test::More tests => 1;
use Alien::Libarchive;
use File::ShareDir qw( dist_dir );
use File::Spec;

pass 'okay';

my $alien = Alien::Libarchive->new;

$ENV{PKG_CONFIG_PATH} = join(':', @{ find_pkgconfig() });

diag '';
diag '';
diag 'type            : ' . $alien->install_type;
diag 'cflags          : ' . $alien->cflags;
diag 'libs            : ' . $alien->libs;
diag 'version         : ' . `pkg-config libarchive --modversion`;
diag 'PKG_CONFIG_PATH : ' . $ENV{PKG_CONFIG_PATH};
diag '';
diag '';


sub find_pkgconfig
{
  my $path = shift || File::Spec->curdir;
  #print "path = $path\n";
  my $list = shift || [];
  opendir(my $dh, $path);
  foreach my $child (readdir $dh)
  {
    next if $child =~ /^\.\.?$/;
    if(-d File::Spec->catdir($path, $child))
    {
      if($child eq 'pkgconfig')
      {
        push $list, File::Spec->catdir($path, $child);
        next;
      }
      find_pkgconfig(File::Spec->catdir($path, $child), $list);
    }
  }
  closedir $dh;
  return $list;
}
