package InfoGopher ;

use 5.026001;
use strict;
use warnings;
use Moose ;

# ABSTRACT: a high-level bot framework for collectiong information bits
our $VERSION = '0.01'; # VERSION

use InfoGopherException ;
use InfoGopher::Intention ;
use InfoGopher::Logger ;
use InfoGopher::InfoSource::RSS ;

use Try::Tiny ;
use Data::Dumper ;

# 
# https://metacpan.org/pod/Moose::Meta::Attribute::Native::Trait::Array
# https://metacpan.org/pod/Moose::Meta::Attribute::Native::Trait::Hash
#
has 'info_sources' => (
    documentation   => 'Array of info sources',
    is              => 'rw',
    isa             => 'ArrayRef[InfoGopher::InfoSource]',
    traits          => ['Array'],
    default         => sub {[]},
    handles => 
        {
        all_info_sources    => 'elements',
        add_info_source     => 'push',
        get_info_source     => 'get',
        count_info_sources  => 'count',
        has_info_sources    => 'count',
        has_no_info_sources => 'is_empty',
        clear_info_sources  => 'clear',
        },
    ) ;


# -----------------------------------------------------------------------------
# collect - trigger fetch for all info sources
#
#
#
sub collect
    {
    my ($self) = @_ ;

    my $i = NewIntention ( 'Collecting bits from datasources' ) ;
    for ( my $i=0; $i < $self->count_info_sources; $i++)
        {
        my $source = $self -> get_info_source($i) ;

        try
            {
            $source -> fetch () ;
            }
        catch
            {
            my $e = $_ ;
            InfoGopher::IntentionStack -> unwind ( $e -> what ) ;
            }
        }
    }

# -----------------------------------------------------------------------------
# render
#
#
#
sub render
    {
    my ($self, $renderer) = @_ ;

    my @result ;
    for ( my $i=0; $i < $self->count_info_sources; $i++)
        {
        my $source = $self -> get_info_source($i) ;
        foreach my $i ( $source -> info_bites )
            {
            foreach my $j ( $i -> all )
                {
                my $r = $renderer -> process ( $j ) ;
                push @result, $r ;
                }
            }
        }
    return \@result ;
    }

sub NewIntention
  {
  my $what = shift ;
  return InfoGopher::Intention -> new( what => $what ) ;
  }

sub ThrowException
  {
  my $what = shift ;
  InfoGopherException::ThrowInfoGopherException($what) ;
  }

__PACKAGE__ -> meta -> make_immutable ;

1;


__END__

=head1 NAME

InfoGopher - Perl Moose Class to collect info bits from a variety of sources.

=head1 SYNOPSIS

  use InfoGopher;

  my $gopher = InfoGopher -> new ;
  my $rss = InfoGopher::InfoSource::RSS -> new ( uri => "http://127.0.0.1:7773") ;

  $gopher -> add_info_source($rss) ;
  $gopher -> collect() ;
  my $bites = $gopher -> info_bites($rss) ;

=head1 DESCRIPTION

Stub documentation for InfoGopher, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Klaus Ramstöck, E<lt>klaus@(none)E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 by Klaus Ramstöck

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.26.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
