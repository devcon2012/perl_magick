#!/usr/bin/perl

# Like it? Use free and include Larry in your prayers.
#

use strict ;
use warnings ;

#use POSIX ":sys_wait_h"; # needed for WNOHANG

use IPC::Open3 ;
use IO::Poll qw(POLLIN POLLERR POLLHUP) ; 
use IO::Handle ;
use IO::File ;

use constant timeout => 3 ;
use Symbol 'gensym' ;

# master has sources below this folder
our $master_src_tree = "/home/klaus/src/owngit/rgdb" ;

# slave doing debugging below this folder
our $slave_src_tree = "/home/klaus/src/hello" ;

our $protofile = "/tmp/rgdb_protocol" ;
our $proto = undef ; # set to 1 to create a protocol
our $proto_map = undef ; # set to 1 to log mapping of src trees

# map masters pathes to slave locations
sub pathmapper_ms
    {
    my $path = shift ;
    print $proto "MS Map $path " if ( $proto_map );
    $path =~ s/\Q$master_src_tree\E/$slave_src_tree/g ;
    print $proto "to $path\n" if ( $proto_map );
    return $path ;
    }

# map slaves pathes to master locations
sub pathmapper_sm
    {
    my $path = shift ;
    print $proto "SM Map $path " if ( $proto_map );
    $path =~ s/\Q$slave_src_tree\E/$master_src_tree/g ;
    print $proto "to $path\n" if ( $proto_map );
    return $path ;
    }

# debug path mapping
# print pathmapper_ms($ARGV[0]) . "\n" ; exit 1 ;

if ( $proto )
    {
    $proto =  IO::File -> new() ; 
    $proto -> open($protofile, "a");
    }
$proto_map &&= $proto ;

# create handles to local streams on master
my $ifh = IO::Handle -> new() ; 
$ifh -> fdopen(fileno(STDIN), "r") ;
$ifh -> autoflush(1) ;

my $ofh = IO::Handle -> new() ; 
$ofh -> fdopen(fileno(STDOUT), "w") ;
$ofh -> autoflush(1) ;

my $efh = IO::Handle -> new() ; 
$efh -> fdopen(fileno(STDERR), "w") ;
$efh -> autoflush(1) ;

# handles to streams on slave
my ($wtr, $rdr, $err) ;
my $cmd = "/usr/bin/ssh" ;
my $args = \@ARGV ;
$err = gensym ;

my $pid = open3($wtr, $rdr, $err, $cmd, 'klaus@goliath', '/usr/bin/gdb', @$args) ;

# Poll for input, HUP and errors
my $poll = IO::Poll -> new() ;
$poll -> mask( $ifh => POLLIN | POLLHUP | POLLERR ) ;
$poll -> mask( $rdr => POLLIN | POLLHUP | POLLERR ) ;
$poll -> mask( $err => POLLIN ) ;
 
while ( 1 )
    {

    # not needed - we get the hup
    # my $kid = waitpid(-1, WNOHANG) ;
    # if ($kid==$pid) 
    #    {
    #    print STDERR "Kid $kid exit with $?\n" ;
    #    exit $? ;
    #    }

    my $nevents = $poll -> poll(timeout) ;
    for my $hin ( $poll -> handles(POLLIN) )
        {
        # INPUT -> Find destination ...
        sysread $hin, my $in, 1024 ;
        if ( $hin == $ifh )
            {
            my $out = pathmapper_ms($in) ;
            syswrite $wtr, $out ; # .. copy stdin to cmd
            print $proto ">> $out" if ( $proto ) ;
            }
        elsif ( $hin == $rdr )
            {
            my $out = pathmapper_sm($in) ;
            syswrite $ofh, $out ; # .. copy cmd out to stdout 
            print $proto "<< $out" if ( $proto ) ;
            }
        else
            {
            my $out = pathmapper_sm($in) ;
            syswrite $efh, $out ; # .. copy cmd err to stderr 
            print $proto "?? $out" if ( $proto ) ;
            }
        }

    for my $hin ( $poll -> handles(POLLHUP) )
        {
        # exit no matter which stream HUPs
        print $proto "Poll gave hup\n" if ( $proto ) ;
        exit 0 ;
        }

    for my $hin ( $poll -> handles(POLLERR) )
        {
        # error exit no matter which stream failed
        print $proto "Poll gave error\n" if ( $proto ) ;
        exit 1 ;
        }
    }
