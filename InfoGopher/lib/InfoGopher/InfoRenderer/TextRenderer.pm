package InfoGopher::InfoRenderer::TextRenderer ;

#
# Renderer returning a plain text variant for 
# any mimetype
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

    my $data = $bite -> data ;
    my $type = $bite -> mime_type ;
    my $time = localtime ( $bite -> time_stamp ) ;

    my $line ;
    if ( $bite -> mime_type =~ /text/ )
        {
        $line = $data . " ($type fetched \@ $time )" ;
        }
    else
        {
        $line = "(binary) ($type fetched \@ $time )" ;
        }
    return $line ;    
    }

__PACKAGE__ -> meta -> make_immutable ;

1;