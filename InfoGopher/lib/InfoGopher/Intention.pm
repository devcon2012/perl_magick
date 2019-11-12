package InfoGopher::Intention ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Moose ;
use MooseX::ClassAttribute ;

use InfoGopher::IntentionStack ;

#

# 
class_has '_serial_counter' => (
    documentation   => 'Intention serial number',
    is              => 'rw',
    isa             => 'Int',
    default         => sub { 1 },
) ;

# 
has 'serial' => (
    documentation   => 'Intention serial number',
    is              => 'rw',
    isa             => 'Int',
    builder         => '_get_serial'
) ;
sub _get_serial
    {
    my $self = shift ;
    my $serial = $self -> _serial_counter ;
    $self -> _serial_counter($serial + 1) ;
    return $serial ;
    }

has 'what' => (
    documentation   => 'Intention string',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

#

sub BUILD
    {
    my $self = shift ;
    InfoGopher::IntentionStack -> add ( $self ) ;
    }

sub DEMOLISH
    {
    my $self = shift ;
    InfoGopher::IntentionStack -> remove ( $self ) ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1 ;
