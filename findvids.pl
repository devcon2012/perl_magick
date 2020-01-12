#!/usr/bin/perl

use strict ;
use warnings ;

use Getopt::Long ;
use File::Find ;
use Data::Dumper ;
use JSON::MaybeXS ;

our ( $opt_verbose, $opt_help, $opt_update, $opt_basedir ) =
    ( undef,        undef,     undef,       $ENV{HOME}.'/Videos' ) ;

our %options = 
        (
        'help|h'            => \$opt_help,
        'verbose|v'         => \$opt_verbose,
        'basedir|b=s'       => \$opt_basedir,
        'update|u'          => \$opt_update,
        ) ;

our $videodb = [] ;

sub logger
    {
    my ($msg) = @_ ;
    print STDERR "$msg\n" if ( $opt_verbose ) ;
    return ;
    }

sub get_video_db_fn
    {
    return $opt_basedir . "/.vindex" ;
    }

sub update_videodb
    {
    logger ( "Find videos in $opt_basedir" ) ;
    my $n = 100 ;
    find( 
        sub 
            {
            if ( $n <= @$videodb)
                {
                logger ( "Got $n videos" ) ; $n += 100 ;
                } 
            if ( /\.[am][vp4][iv4]$/ )
                {
                my $info = {} ; 
                $info -> {name} = $File::Find::name ;
                my @s = stat ( $File::Find::name )  ;
                $info -> {size} = $s[7] ;
                $info -> {date} = $s[9] ;
                push @$videodb, $info ; 
                }
            } ,
        $opt_basedir
        ) ;
    $n = @$videodb ;
    logger ( "Got $n videos" ) ;
    }

sub load_videodb
    {
    my $db_fn = get_video_db_fn () ;
    open (my $fh, "<", $db_fn) 
        or die ( "cannot open for read $db_fn: $!" ) ;
    local $/ = undef ;
    my $dbtxt = <$fh> ;
    close ($fh) ;
    $videodb = JSON -> new -> decode( $dbtxt ) ;
    my $n = @$videodb ;
    logger ( "Loaded $n entries from $db_fn" ) ;
    }

sub save_videodb
    {
    my $db_fn = get_video_db_fn () ;
    open (my $fh, ">", $db_fn) 
        or die ( "cannot open for write $db_fn: $!" ) ;
    print $fh JSON -> new -> encode( $videodb ) ;
    close ($fh) ;
    my $n = @$videodb ;
    logger ( "Wrote $n entries to $db_fn" ) ;
    }

sub find_videos
    {
    my ( $db, $pattern) = @_ ;

    my $n = scalar @$db ;

    print "Got $n vids\nSearch $pattern\n";
    foreach ( @$db )
        {
        my ( $name, $size, $date ) = ( $_ -> {name}, $_ -> {size}, $_ -> {date}, ) ;
        $size = int ( $size / (1024*1024) ) . " MByte" ;
        $date = localtime ($date) ;
        if ( $name =~ /\Q$pattern\E/i )
            {
            print "$name: $size from $date\n"
            }
        }
    }

GetOptions( %options ) or pod2usage(2) ;

my $def = ( $0 =~ /findweb/ ? 'WEBBASE' : 'VIDBASE' ) ;
$opt_basedir //= $ENV{$def}  if ( $ENV{$def}) ; 

if ( ! -d $opt_basedir )
    {
    die ("No such dir: $opt_basedir") ;
    }

if ( $opt_update )
    {
    update_videodb ;
    save_videodb ;
    }
else
    {
    load_videodb ;
    find_videos ( $videodb, shift ) ;
    }
