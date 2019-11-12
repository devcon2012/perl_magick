package InfoGopher::InfoSource::RSS ;

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
with 'InfoGopher::InfoSource::_InfoSource' ;

# -----------------------------------------------------------------------------
# fetch - get fresh copy from RSS InfoSource
#
#
sub fetch
    {
    my ($self) = @_ ;

    my $i = InfoGopher::NewIntention ( 'Fetch RSS ' . $self -> uri ) ;

    $self -> get_http ;
    $self -> info_bites -> clear() ;

    $self -> add_info_bite ( 
            $self -> raw, 
            $self -> response -> header('content-type'),
            time ) ;

    }

__PACKAGE__ -> meta -> make_immutable ;

1;
