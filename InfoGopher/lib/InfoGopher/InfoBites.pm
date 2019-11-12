package InfoGopher::InfoBites ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Data::Dumper;
use Moose;
use Try::Tiny;

use InfoGopher::InfoBites ;

has 'bites' => (
    documentation   => 'Array of info bites',
    is              => 'rw',
    isa             => 'ArrayRef[InfoGopher::InfoBite]',
    traits          => ['Array'],
    default         => sub {[]},
    handles => {
        all         => 'elements',
        add         => 'push',
        get         => 'get',
        count       => 'count',
        has_info    => 'count',
        has_no_info => 'is_empty',
        clear       => 'clear',
    },
) ;

__PACKAGE__ -> meta -> make_immutable ;

1;