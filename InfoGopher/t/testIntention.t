
use strict;
use warnings;

use Test::More tests => 15 ;
use Try::Tiny ;
use Data::Dumper ;

BEGIN { use_ok('InfoGopher') };
BEGIN { use_ok('InfoGopher::Intention') };
BEGIN { use_ok('InfoGopher::IntentionStack') };

#########################

my $intention = InfoGopher::NewIntention ( 'test1' ) ;
    {
    my $i = InfoGopher::NewIntention ( 'test2' ) ;
    ok ( ! InfoGopher::IntentionStack -> is_corrupted ) ;
    undef $i ;
    ok ( ! InfoGopher::IntentionStack -> is_corrupted ) ;
    }
undef $intention ;
ok ( ! InfoGopher::IntentionStack -> is_corrupted ) ;

$intention = InfoGopher::NewIntention ( 'test1b' ) ;
    {
    my $i = InfoGopher::NewIntention ( 'test2b' ) ;
    ok ( ! InfoGopher::IntentionStack -> is_corrupted ) ;
        {
        my $i = InfoGopher::NewIntention ( 'test3b' ) ;
        ok ( ! InfoGopher::IntentionStack -> is_corrupted ) ;
        }
    }
ok ( ! InfoGopher::IntentionStack -> is_corrupted ) ;
    {
    my $i1 = InfoGopher::NewIntention ( 'test3b' ) ;
    ok ( ! InfoGopher::IntentionStack -> is_corrupted ) ;

    my $i2 = InfoGopher::NewIntention ( 'test4b' ) ;
    ok ( ! InfoGopher::IntentionStack -> is_corrupted ) ;
    undef ( $i1 ) ;

    ok ( InfoGopher::IntentionStack -> is_corrupted ) ;
    }

undef $intention ;
InfoGopher::IntentionStack -> reset ;
ok ( ! InfoGopher::IntentionStack -> is_corrupted ) ;

$intention = InfoGopher::NewIntention ( 'test1c' ) ;

my $stack = InfoGopher::IntentionStack -> unwind ("bla") ;
#print STDERR Dumper($stack) ;

ok ( 1 == scalar @$stack ) ;

my $intention2 = InfoGopher::NewIntention ( 'test1d' ) ;
$stack = InfoGopher::IntentionStack -> unwind ("bla") ;
ok ( 2 == scalar @$stack ) ;

exit 0 ;
