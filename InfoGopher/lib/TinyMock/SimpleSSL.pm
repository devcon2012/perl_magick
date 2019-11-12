package TinyMock::SimpleSSL ;

use strict ;
use warnings ;
use Moose ;

extends 'TinyMock::Simple' ;

use IO::Handle ;
use IO::File ;
use IO::Socket::SSL ;

use Data::Dumper ;
use constant timeout => 3 ;
use Symbol 'gensym' ;
use Getopt::Long ;

# 
sub _build_default_port { 7774 }

has 'crypto' => (
    documentation   => 'crypto file name base',
    is              => 'rw',
    isa             => 'Str',
    default         => '',
) ;


# - main ----------------------------------------------------------------------


# -----------------------------------------------------------------------------
# setup module 
#
# in    $content_fn
#       [$response
#       [$port 
#
sub setup
    {
    my ($self, $crypto, $content_fn, $response, $port) = @_ ;

    $self -> crypto ( $crypto ) ;

    return $self -> SUPER::setup( $content_fn, $response, $port ) ;
    }

sub build_socket
    {
    my ( $self ) = @_;

    my $crypto = $self -> crypto ;
    my $port = $self -> port ;

    my $crt = $crypto . ".crt" ;
    my $key = $crypto . ".key" ;

    if ( ! -r $crt || ! -r $key )
        {
        die "At least one of $crt/$key not readable" ;
        }

    my $socket = IO::Socket::SSL->new(
            LocalAddr       => '127.0.0.1',
            LocalPort       => $port,
            Listen          => 10,
            SSL_cert_file   => $crt,
            SSL_key_file    => $key,
            Reuse => 1
        ) or die "failed to create SSL socket on $port: $! ($SSL_ERROR) " ;

    return ( $socket, "Listening on 127.0.0.1:$port, cert/key basename $crypto\n" ) ;

    }

sub accept_fail_msg 
    {
    return "Failed to SSL accept on " . shift -> port . "($SSL_ERROR)" ;
    }


1 ;