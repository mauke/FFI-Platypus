use strict;
use warnings;
use ExtUtils::CBuilder;
use Text::ParseWords qw( shellwords );
use lib 'inc';
use My::Once;
use My::AutoConf;
use My::Probe;
use My::Dev;
use My::ShareConfig;

My::Once->check('config');

My::Dev->generate;

My::AutoConf->configure;

my $share_config = My::ShareConfig->new;

{
  my $class = $share_config->get('alien')->{class};
  my $pm = "$class.pm";
  $pm =~ s/::/\//g;
  require $pm;
  $share_config->set(extra_compiler_flags => [ shellwords($class->cflags) ]);
  $share_config->set(extra_linker_flags   => [ shellwords($class->libs) ]);
  $share_config->set(ccflags => $class->cflags);
}

My::Probe->probe(
  ExtUtils::CBuilder->new( config => { ccflags => $share_config->get('ccflags') }),
  $share_config->get('ccflags'),
  [],
  $share_config->get('extra_linker_flags'),
);
unlink $_ for My::Probe->cleanup;

My::Once->done;
