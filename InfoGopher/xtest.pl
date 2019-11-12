#!/usr/bin/perl

use strict ;
use warnings ;

use lib '/home/klaus/src/owngit/perl_magick/InfoGopher/lib' ;

use Try::Tiny ;


#
# make testdb TEST_FILE=t/mytest.t
# make test TEST_VERBOSE=1
# make test TEST_FILES='t/InfoGopherException.t'

use InfoGopher ;
use InfoGopher::InfoSource::RSS ;
use InfoGopher::Intention ;
use InfoGopher::IntentionStack ;

use TinyMock::HTTP ;

our $mock ;

BEGIN 
    { 
    $ENV{'MOCK_HOME'} = '/home/klaus/src/owngit/perl_magick/InfoGopher/TinyMock'; 
    $mock = TinyMock::HTTP -> new ();
    $mock -> setup('four_o_four', 7080) ; 
    } ;

my $rss = InfoGopher::InfoSource::RSS -> new ( uri => "http://127.0.0.1:7080") ;

my $i = InfoGopher::NewIntention ( 'test' ) ;

try
    {
    my $i = InfoGopher::NewIntention( 'update1' ) ;
        {
        my $i = InfoGopher::NewIntention( 'fetch rss' ) ;
        $rss -> fetch ;
        }
    }
catch
    {
    my $e = $_ ;
    InfoGopher::IntentionStack -> unwind($e -> what) ;
    };

$mock -> set_responsefile_content('RSS') ;     

try
    {
    my $i = InfoGopher::Intention -> new (what => 'update2' ) ;
    $rss -> fetch ;
    }
catch
    {
    my $e = $_ ;
    InfoGopher::IntentionStack -> unwind($e -> what) ;
    };

InfoGopher::IntentionStack -> unwind("Final unwind") ;

$rss -> dump_info_bites ;

END 
    { 
    $mock -> shutdown() ; 
    } ;
