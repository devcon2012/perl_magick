# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl InfoGopher.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 2;

use lib '/home/klaus/src/owngit/perl_magick/InfoGopher/lib' ;

use TinyMock ;

BEGIN { TinyMock::setup("RSS"); }

BEGIN { use_ok('InfoGopher::InfoSource::RSS') };

#########################

my $rss = InfoGopher::InfoSource::RSS -> new ( uri => "http://127.0.0.1:7773") ;

$rss -> fetch () ;

END { TinyMock::shutdown(); }
