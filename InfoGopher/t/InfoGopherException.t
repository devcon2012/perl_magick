# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl InfoGopherException.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 3;

use Try::Tiny ;

use lib '/home/klaus/src/owngit/perl_magick/InfoGopher/lib' ;

BEGIN { use_ok('InfoGopherException') };

try 
    {
    InfoGopherException::ThrowInfoGopherException("XX") ;
    }
catch
    {
    my $e = $_ ;
    note( ref $e ) ;
    ok ( 'InfoGopher::Exception' eq ref $e ) ;
    ok ( 'XX' eq $e -> what ) ;
    };

#########################



