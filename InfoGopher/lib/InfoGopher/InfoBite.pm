package InfoGopher::InfoBite ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Data::Dumper;
use Moose;
use Try::Tiny;

# 
has 'data' => (
    documentation   => 'Information data',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

has 'mime_type' => (
    documentation   => 'info mime type',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    lazy            => 1,
    default         => ''
) ;

#has 'meta' => (
#    documentation   => 'meta info- filenames eg.',
#    is              => 'rw',
#    isa             => 'HashRef[Any]',
#    lazy            => 1,
#    default         => sub { {} },
#) ;

has 'time_stamp' => (
    documentation   => 'Timestamp obtained',
    is              => 'rw',
    isa             => 'Int',
    default         => sub { time ;}
) ;

#


__PACKAGE__ -> meta -> make_immutable ;

1;