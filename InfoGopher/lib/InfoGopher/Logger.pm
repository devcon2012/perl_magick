package InfoGopher::Logger ;

use strict ;
use warnings ;

use Moose ;
use MooseX::ClassAttribute ;

# 
class_has 'handle' => (
    documentation   => 'logger file handle',
    is              => 'rw',
    isa             => 'Any',
    lazy            => 1,
    builder         => '_build_log_destination' ,
) ;
sub _build_log_destination
    {
    open ( my $fh , '>', '/tmp/InfoLogger.txt' )
        or die "cannont open infologger: $!" ;
    return $fh ;
    }

sub log
    {
    my ($self, $msg) = @_  ;
    my $fh = $self -> handle ;

    print STDERR "$msg\n" ;
    print $fh "$msg\n" ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;