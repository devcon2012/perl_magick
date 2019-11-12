package InfoGopher::Exception ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean ;

use Moose;

has 'what' => (
    documentation   => 'exception error message',
    is              => 'rw',
    isa             => 'Str',
    lazy            => 1,
    default         => '???',
) ;

__PACKAGE__ -> meta -> make_immutable ;

1;