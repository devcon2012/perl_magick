package InfoGopher::InfoRenderer::RawRenderer ;

#
# Renderer returning raw infobite data
#

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Moose;

extends 'InfoGopher::InfoRenderer' ;
with 'InfoGopher::InfoRenderer::_InfoRenderer' ;

# -----------------------------------------------------------------------------
# process - render one bite of info
#
# in $bite - one info bite
#
# ret $info - rendered info bite
#
sub process
    {
    my ($self, $bite) = @_ ;
    return $bite -> data ;

    }

__PACKAGE__ -> meta -> make_immutable ;

1;