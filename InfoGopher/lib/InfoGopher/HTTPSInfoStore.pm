package InfoGopher::HTTPSInfoSource ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;


# use Devel::StealthDebug;
# !! xassert($foo != 0)!
# !! xwatch(%myhash)!
# !! xdump(%myhash)!
# !! xemit(Entering func1)!

use Data::Dumper;
use Moose;
use Try::Tiny;

extends 'InfoGopher::HTTPInfoSource' ;


use constant source_type => 'virtual_base_class' ;

has 'ca_store' => (
    documentation   => 'https ca store',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ""
) ;

has 'allow_unencrypted' => (
    documentation   => 'allow unencrypted reads',
    is              => 'rw',
    isa             => 'Int',
    default         => 0
) ;

has 'allow_untrusted' => (
    documentation   => 'allow read from untrusted sources',
    is              => 'rw',
    isa             => 'Int',
    default         => 1
) ;


sub get_https
    {
    my ($self) = @_ ;

    }

__PACKAGE__ -> meta -> make_immutable ;

1;
