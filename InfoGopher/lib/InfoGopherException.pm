package InfoGopherException ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean ;

require Exporter ;
our @EXPORT = qw(ThrowInfoGopherException) ;

use InfoGopher::Exception ;
use InfoGopher::IntentionStack ;

# -----------------------------------------------------------------------------
# ThrowInfoGopherException - die with an InfoGopher::Exception
#
sub ThrowInfoGopherException
    {
    my $e = InfoGopher::Exception -> new ( what => shift ) ;
    InfoGopher::IntentionStack -> freeze ( 1 ) ;
    die $e ;
    }

1;