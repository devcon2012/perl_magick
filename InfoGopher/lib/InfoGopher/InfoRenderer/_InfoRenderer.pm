package InfoGopher::InfoRenderer::_InfoRenderer ;

# role to prevent instantiation of an incomplete InfoRenderer ;

use Moose::Role ;
 
requires 'process' ;

# -----------------------------------------------------------------------------
# process - render one bite of info
#
# in $bite - one info bite
#
# ret $info - rendered info bite
#
#sub process
#    {
#    my ($self, $bite) = @_ ;
#
#    .....
#    }

1;

 