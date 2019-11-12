# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl InfoGopher.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 6;

use TinyMock::HTTP ;
use Try::Tiny ;

BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::InfoSource::RSS') };
BEGIN { use_ok('InfoGopher::InfoRenderer::TextRenderer') };

our $mock ;

BEGIN 
    { 
    $mock = TinyMock::HTTP -> new ();
    $mock -> setup('four_o_four', 7081) ; 
    } ;

#########################

my $gopher = InfoGopher -> new ;
my $rss = InfoGopher::InfoSource::RSS -> new ( uri => "http://127.0.0.1:7081") ;

$gopher -> add_info_source($rss) ;
try
    {
    $gopher -> collect() ;
    }
catch
    {
    ok ('Failed due to 404') ;
    };

$mock -> set_responsefile_content('RSS') ;     

ok ('1') ;

$gopher -> collect() ;

my $renderer = InfoGopher::InfoRenderer::TextRenderer -> new ;
my @result = $gopher -> render( $renderer) ;
ok ( 1 == scalar @result ) ;
ok ('2') ;

exit 0 ;

END 
    { 
    $mock -> shutdown() ; 
    } ;

