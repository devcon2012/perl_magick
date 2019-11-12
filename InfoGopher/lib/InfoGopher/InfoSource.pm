package InfoGopher::InfoSource ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;


# use Devel::StealthDebug;
# !! xassert($foo != 0)!
# !! xwatch(%myhash)!
# !! xdump(%myhash)!
# !! xemit(Entering func1)!

use Data::Dumper;
use Moose;
use Try::Tiny;

use InfoGopher::InfoBites ;
use InfoGopher::InfoBite ;
use InfoGopher::InfoRenderer::TextRenderer ;

use constant source_type => 'virtual_base_class' ;

# 
has 'uri' => (
    documentation   => 'Information source, eg. http://xxx.. or ...',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

has 'raw' => (
    documentation   => 'Raw data obtained',
    is              => 'rw',
    isa             => 'Maybe[Str]',
    default         => ''
) ;

has 'last_fetch' => (
    documentation   => 'Timestamp last raw data obtained',
    is              => 'rw',
    isa             => 'Int',
    default         => 0
) ;

has 'info_bites' => (
    documentation   => 'info_bites obtained',
    is              => 'rw',
    isa             => 'InfoGopher::InfoBites',
    lazy            => 1,
    builder         => '_build_info_bites',
) ;
sub _build_info_bites
    {
    return InfoGopher::InfoBites -> new () ;
    }

#
#

# -----------------------------------------------------------------------------
# add_info_bite - factory method to add a new info bite to the list
#
# in    $data
#       $mime_type
#       $time_stamp
#
sub add_info_bite
    {
    my ( $self, $data, $mime_type, $time_stamp) = @_ ;

    my $bite = InfoGopher::InfoBite -> new ( 
            data        => $data,
            mime_type   => $mime_type,
            time_stamp  => $time_stamp
            ) ;
    $self -> info_bites -> add( $bite ) ;
    }


# -----------------------------------------------------------------------------
# dump_info_bites - dump into bites as text (for debugging)
#
#
sub dump_info_bites
    {
    my ( $self ) = @_ ;

    my $renderer = InfoGopher::InfoRenderer::TextRenderer -> new ;
    foreach ( $self -> info_bites -> all )
        {
        print STDERR $renderer -> process ($_) . "\n" ;
        } 
    }

__PACKAGE__ -> meta -> make_immutable ;

1;