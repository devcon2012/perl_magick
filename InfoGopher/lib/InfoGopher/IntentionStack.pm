package InfoGopher::IntentionStack ;

use strict ;
use warnings ;
use utf8 ;
use namespace::autoclean;

use Moose ;
use MooseX::ClassAttribute ;

use InfoGopher::IntentionSummary ;

# 
class_has '_stack' => (
    documentation   => 'Intention id stack',
    is              => 'rw',
    isa             => 'ArrayRef[Int]',
    traits          => ['Array'],
    default         => sub {[]},
    handles => {
        all_intentions      => 'elements',
        add_intention       => 'push',
        get_intention       => 'get',
        count_intentions    => 'count',
        has_intention       => 'count',
        clear_intentions    => 'clear',
        pop_intention       => 'pop',
    },
) ;

class_has '_map' => (
    documentation   => 'Map intention ids to summaries',
    is              => 'rw',
    isa             => 'HashRef[InfoGopher::IntentionSummary]',
    traits          => ['Hash'],
    default         => sub { {} },
    handles         => {
        set_summary       => 'set',
        get_summary       => 'get',
        delete_summary    => 'delete',
        delete_summaries  => 'clear'
        },
    ) ;

# 
class_has '_queue' => (
    documentation   => 'queue pop operations while in frozen state',
    is              => 'rw',
    isa             => 'ArrayRef[Int]',
    traits          => ['Array'],
    default         => sub {[]},
    handles => {
        queue         => 'elements',
        queue_push    => 'push',
        queue_element => 'get' ,
        queue_size    => 'count',
        clear_queue   => 'clear',
    },
) ;

class_has '_frozen' => (
    documentation   => 'Intention stack frozen state flag',
    is              => 'rw',
    isa             => 'Int',
    default         => sub { 0 },
    ) ;

class_has '_corrupted' => (
    documentation   => 'Intention stack corrupted flag (popped non-top element)',
    is              => 'rw',
    isa             => 'Int',
    default         => sub { 0 },
    ) ;

# -----------------------------------------------------------------------------
# freeze - queue intention removes, dont perform them
#
sub freeze
    {
    shift -> _frozen(1) ;
    }

# -----------------------------------------------------------------------------
# thaw - perform queued intention removes
#
sub thaw
    {
    my $self = shift ;

    $self -> _frozen(0) ;
    for ( my $i=0; $i < $self -> queue_size; $i++ )
        {
        my $id      = $self -> queue_element($i) ;
        my $head    = $self -> get_intention(-1) ;
        my $summary = $self -> get_summary($head) ;
        my $text    = $summary -> what ;
        if ( ! $self -> remove_id($id) )
            {
            InfoGopher::Logger -> log ("Intention stack thaw: $id did not match $head ($text) on top" );
            }
        }
    $self -> clear_queue ;

    }

# -----------------------------------------------------------------------------
# summary - create new intention summary
#
# in    $intention
#
# ret   $summary
#
sub summary
    {
    my ($self, $intention) = @_ ; 
    return InfoGopher::IntentionSummary::extract($intention) ;
    }

# -----------------------------------------------------------------------------
# reset - cleanup after corruption
#
#
sub is_corrupted
    {
    my ($self ) = @_ ; 
    return $self -> _corrupted  ;
    }

# -----------------------------------------------------------------------------
# reset - cleanup after corruption
#
#
sub reset
    {
    my ($self ) = @_ ; 
    $self -> delete_summaries ;
    $self -> clear_intentions ;
    $self -> clear_queue ;
    $self -> _corrupted (0) ;
    $self -> _frozen (0) ;
    }

# -----------------------------------------------------------------------------
# add - push intention on stack top
#
# in    $intention
#
sub add
    {
    my ($self, $intention) = @_ ; 

    my $id = $intention -> serial ;
    my $text = $intention -> what ;

    if ( $self -> _frozen )
        {
        InfoGopher::Logger -> log ( "Tried to add $id:$text in frozen state" ) ;
        }
    else 
        {
        my $summary =  $self -> summary ($intention) ;
        my $msg = $self -> format_summary ( "Start ", $summary ) ;
        InfoGopher::Logger -> log ( $msg ) ;        
        $self -> add_intention ($id) ;
        $self -> set_summary ( $id, $summary ) ;
        }
    }

# -----------------------------------------------------------------------------
# format_summary
#
# in    $prefix
#       $intention_summary
#
# ret   $string
#
sub format_summary
    {
    my ($self, $prefix, $summary) = @_ ; 

    my $id = $summary -> serial ;
    my $text = $summary -> what ;
    my $t = $summary -> timestamp ;

    my $depth = $self -> count_intentions + 1 ;

    my $line = ('>' x $depth) . "$prefix (" . localtime($t) . ") $id- $text" ;
    return $line ;
    }

# -----------------------------------------------------------------------------
# remove - pop intention stack
#
# in    $intention
#
sub remove
    {
    my ($self, $intention) = @_ ; 

    my $id = $intention -> serial ;
    my $text = $intention -> what ;

    if ( $self -> _frozen )
        {
        $self -> queue_push ( $id ) ;
        }
    else 
        {
        my $summary =  $self -> summary ($intention) ;
        my $msg = $self -> format_summary ( "End ", $summary ) ;
        InfoGopher::Logger -> log ( $msg ) ;        
        if ( ! $self -> remove_id($id) )
            {
            InfoGopher::Logger -> log( "Intention stack remove: $id ($text) was not on top" );
            }
        }
    }

# -----------------------------------------------------------------------------
# remove_id - pop intention stack
#
# in    $id - intention id
#
sub remove_id
    {
    my ($self, $id) = @_ ; 

    my $id2 = $self -> get_intention( -1 ) ;
    $self -> pop_intention () ;
    $self -> delete_summary ( $id ) ;
    $self -> _corrupted(1) 
        if ( ! ($id == $id2) ) ;
    return  ( $id == $id2 )  ;
    }

# -----------------------------------------------------------------------------
# unwind - dump intention stack. will thaw afterwards
#
# in    $msg - msg printed before dump
#
sub unwind
    {
    my ($self, $msg) = @_ ;

    InfoGopher::Logger -> log( "Exception: $msg" ) ;

    my @stack ;
    foreach ( $self -> all_intentions )
        {
        my $line =  "$_: " . $self -> get_summary ( $_ ) -> what . ".";
        InfoGopher::Logger -> log( $line ) ;
        push @stack, $line ;
        }

    $self -> thaw ;
    
    return \@stack ;
    }

__PACKAGE__ -> meta -> make_immutable ;

1;