#!/usr/bin/perl

use strict ;
use warnings ;

use lib '/home/klaus/src/owngit/perl_magick/InfoGopher/lib' ;

use TinyMock ;

TinyMock::main() ;
sub main
    {

    GetOptions(@$options) ;

    run() ;
    }

