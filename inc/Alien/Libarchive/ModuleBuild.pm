package Alien::Libarchive::ModuleBuild;

use strict;
use warnings;
use base qw( Alien::Base::ModuleBuild );
use FindBin ();
use Text::ParseWords qw( shellwords );

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

my $cflags;
my $libs;
  
sub alien_do_commands
{
  my($self, $phase) = @_;

  unless(defined $cflags)
  {
    my $first = 1;
    foreach my $dep ([ qw( Alien::Libxml2 Alien::LibXML ) ], qw( Alien::OpenSSL Alien::bz2 ))
    {
      my @dep = ref $dep ? @$dep : ($dep);
      $DB::single = 1;
      foreach my $name (@dep)
      {
        my $alien = eval qq{ require $name; $name->new };
        next if $@;
        print "\n\n" if $first; $first = 0;
        print "  trying to use $name: ";
      
        require ExtUtils::CChecker;
        require Capture::Tiny;
      
        my $cc = ExtUtils::CChecker->new;
        $cc->push_extra_compiler_flags(shellwords ' ' . $alien->cflags);
        $cc->push_extra_linker_flags(shellwords  ' ' . $alien->libs);
        my $ok;
        my $out = Capture::Tiny::capture_merged(sub {
          $ok = $cc->try_compile_run("int main(int argc, char *argv[]) { return 0; }");
        });
        if($ok)
        {
          print "ok\n";
          $cflags .= ' ' . $alien->cflags;
          $libs   .= ' ' . $alien->libs;
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
  }

  local $ENV{CFLAGS} = $cflags;
  local $ENV{LIBS}   = $libs;
  
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
