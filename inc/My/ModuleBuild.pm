package My::ModuleBuild;

use strict;
use warnings;
use base qw( Alien::Base::ModuleBuild );
use FindBin ();
use Text::ParseWords qw( shellwords );
use Config;

sub new
{
  my $class = shift;
  if($^O eq 'MSWin32')
  {
    return Module::Build->new(@_);
  }
  else
  {
    return $class->SUPER::new(
      "alien_build_commands" => [
        "%x -I../../inc -MMy::ModuleBuild -e alien_patch",
        "%pconfigure --prefix=%s --disable-bsdtar --disable-bsdcpio",
        "make",
        "make DESTDIR=%d/_test install"
      ],
      "alien_name" => "libarchive",
      "alien_repository" => {
        "host" => "www.libarchive.org",
        "location" => "/downloads/",
        "pattern" => "^libarchive-([\\d\\.]+)\\.tar\\.gz\$",
        "protocol" => "http"
      },
      @_,
    );
  }
}

my $cflags;
my $libs;
  
sub alien_do_commands
{
  my($self, $phase) = @_;

  unless(defined $cflags)
  {
    require ExtUtils::CChecker;
    require Capture::Tiny;
    my $cc = ExtUtils::CChecker->new;

    my $first = 1;
    foreach my $dep ([ qw( Alien::Libxml2 Alien::LibXML ) ], qw( Alien::OpenSSL Alien::bz2 ))
    {
      my @dep = ref $dep ? @$dep : ($dep);
      foreach my $name (@dep)
      {
        my $alien = eval qq{ require $name; $name->new };
        next if $@;
        print "\n\n" if $first; $first = 0;
        print "  trying to use $name: ";
      
        $cc->push_extra_compiler_flags(shellwords ' ' . $alien->cflags);
        $cc->push_extra_linker_flags(shellwords  ' ' . $alien->libs);
        my $ok;
        my $out = Capture::Tiny::capture_merged(sub {
          $ok = $cc->try_compile_run(
            source               => "int main(int argc, char *argv[]) { return 0; }",
            extra_compiler_flags => [shellwords($alien->cflags)],
            extra_linker_flags   => [shellwords($alien->libs)],
          );
        });
        if($ok)
        {
          print "ok\n";
          $libs   .= ' ' . $alien->libs;
          $cc->push_extra_compiler_flags(shellwords $alien->cflags);
          $cc->push_extra_linker_flags($alien->libs);
          last;
        }
        else
        {
          print "failed\n";
          print $out;
        }
      }
    }
    print "\n\n" unless $first;

    $cflags = join ' ', $Config{optimize}, $Config{cccdlflags}, @{ $cc->extra_compiler_flags };

  }
  

  local $ENV{CFLAGS} = $cflags;
  local $ENV{LIBS}   = $libs;
  
  print "CFLAGS=$cflags\n";
  print "LIBS=$libs\n";
  
  $self->SUPER::alien_do_commands($phase);
}

sub alien_check_installed_version {
  my($self) = @_;

  return if ($ENV{ALIEN_LIBARCHIVE}||'') eq 'share';

  require ExtUtils::CChecker;
  require Capture::Tiny;
      
  my $cc = ExtUtils::CChecker->new;
  $cc->push_extra_linker_flags('-larchive');
  
  my $ok = 0;
  my $out = Capture::Tiny::capture_merged(sub {
    $ok = $cc->try_compile_run(
      join("\n", 
        '#include <archive.h>',
        'int main(int argc, char *argv[])',
        '{',
        '  printf("version: %s\n", archive_version_string());',
        '  return 0;',
        '}',
        '',
      ),
    );
  });

  if($ok && $out =~ /version: libarchive ([0-9.]+)/)
  {
    print "\n\n  using operating system by guess version $1\n\n";
    $self->config_data( system_no_pkg_config => 1 );
    return $1;
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
