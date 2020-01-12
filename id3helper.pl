#!/usr/bin/perl 

#
# See https://de.wikipedia.org/wiki/ID3-Tag#ID3v2
#
use strict ;
use Data::Dumper ;
use Getopt::Long ;
use PerlIO::encoding;
use utf8 ;
use Encode;

#
#
# map id3v2 tags to command line opts
use constant id3v2mapping =>
    {
    'TPE1 (Lead performer(s)/Soloist(s))'       => 'artist',
    'TIT2 (Title/songname/content description)' => 'song'
    } ;

our ( $opt_verbose, $opt_force, $opt_sim ) ;

sub usage
    {
    print STDERR "Usage: id3helper.pl [options] [glob]\n" .
        "   --force | -f: force creation of id3 tags even if they exits\n" .
        "   --help | -h: show this help\n" .
        "   --sim | -s: simulate only, dont change anything\n" .
        "   --verbose | -v: Show what is going on\n" .
        "   the glob pattern determins which files are proccessed\n" . 
        "   Artist and track are determined from filename: artist-track-xxx.mp3\n" ;
    exit 1 ;
    }

sub load_db
    {
    my ($artistdbfn) = @_ ;
    my $artists = {} ;
    my $mappings = {} ;

    open my $db, "<", $artistdbfn 
        or warn "no db $artistdbfn";

    if ($db)
        {
        local $/ = undef ;
        # switch of utf8 because conversion is done upon read
        my $dbdata = "no utf8; " . <$db> ;
        close ($db) ;
        eval $dbdata ;
        die "Database corrupted" 
            if ( 'HASH' ne ref $artists );
        die "Database corrupted: $@" 
            if ( $@ );
        my $entries = scalar keys %$artists ;
        print "Artist Database has $entries keys\n" ;
        foreach (keys %$artists )
            {
            my $v = $artists -> {$_} ;
            next if ( $v==1);
            $mappings -> {$_} = $v ;
            }
        my $entries = scalar keys %$mappings ;
        print "Mappings Database has $entries keys\n" ;
        }
    return ($artists, $mappings) ;
    }

sub save_db
    {
    my ($artistdbfn, $artists, $mappings) = @_ ;

    return if ( $opt_sim ) ;

    system("cp $artistdbfn $artistdbfn.last") ;

    open my $db, ">", $artistdbfn 
        or warn "cannot write $artistdbfn: $!";
    
    my $d = Data::Dumper -> new( [$artists, $mappings] , [qw(artists mappings)]) ;
    $d -> Sortkeys(1) ;
    print $db $d -> Dump ;
    close ($db) ;

    }

sub print_data
    {
    foreach (@_)
        {
        if ( 'ARRAY' eq ref $_ )
            {
            print join ';', @$_ ;
            }
        elsif ( 'HASH' eq ref $_ )
            {
            my $c ="";
            foreach my $k ( sort keys %$_ )
                {
                my $v = $_->{$k} ;
                print "$c$k=>$v" ;
                $c = ';';
                }
            }
        else
            {
            print $_ ;
            }
        }
    print "\n" ;
    }

# Apply mapping of artists, eg cruxshadows -> CrüxShadows
# returns undef if nothing to map
sub map_artist
    {
    my ($a, $artists) = @_ ;
    $artists -> {$a} = 1
        if ( ! exists $artists -> {$a} ) ;
    my $ma = $artists -> {$a} ;
    return ( $ma != 1 ? $ma : undef );
    }

#
# select variant used for read
#
sub get_id3tags
    {
    return get_id3tags_v2(@_) ;
    }

# per std, id3tags are iso-8859-1
#
#
sub get_id3tags_v2
    {
    my $fn = shift ;
    $fn =~ s/'/\?/g ;
    #print STDERR ">$fn<\n" ;
    open my $id3, "-|", "/usr/bin/id3v2 -l '$fn'"
        or die "cannot open '$fn': $!";
    my $id3v2 ;
    my %ret ;
    my $mapping = id3v2mapping ;
    while (<$id3>)
        {
        #print STDERR "v2 - in :$_";
        chomp $_ ;
        my $data = encode("UTF-8", decode("iso-8859-1", $_));
        return {} if ( $data =~ /no id3 tag/i ) ;
        if ( $data =~ /^id3v2 tag info/i )
            {
            $id3v2 = 1 ;
            next ;
            }
        next if ( ! $id3v2 ) ;
        print STDERR "v2 - data :$data\n";
        my ($key, $value) = $data =~ /([^\:]+):\s+(.+)\s*$/;
        $key   =~ s/^\s+//g ;
        $key   =~ s/\s+$//g ;
        next if ( ! $mapping->{$key} );
        $value =~ s/^\s+//g ;
        $value =~ s/\s+$//g ;
        $key = ( $mapping->{$key} ? $mapping->{$key} : $key ) ;
        $ret{$key} = $value if ( $value ne '1' ) ;
        #print "$key -> $value\n" ;
        }
    print_data("File $fn has v2 tags: ", \%ret ) 
        if ( $opt_verbose ) ;
    return \%ret ;
    }

sub get_id3tags_v1
    {
    my $fn = shift ;
    $fn =~ s/'/\?/g ;
    #print STDERR ">$fn<\n" ;
    open my $id3, "-|:encoding(iso-8859-1)", "/usr/bin/id3v2 -l '$fn'"
        or die "cannot open '$fn': $!";
    my %ret ;
    while (<$id3>)
        {
        chomp $_ ;
        print STDERR "-->$_\n" ;
        next if ( $_ !~ /^Title\s+\:/ ) ;
        #my ($t, $a) = $_ =~ /^Title\s+\:(.+)\s+Artist\s+\:(.+)$/ ;
        my ($t) = $_ =~ /^Title\s+\:(.+)/ ;
        $t =~ s/\s+Artist.+//g;
        my ($a) = $_ =~ /Artist\s*\:(.+)/ ;
        $t  =~ s/^\s+//g ;
        $t  =~ s/\s+$//g ;
        $a  =~ s/^\s+//g ;
        $a  =~ s/\s+$//g ;
        print STDERR "+$t+$a+\n" ; exit 0;
        $ret{artist} = $a ;
        $ret{song} = $t ;
        last ;
        }
    print_data("File $fn has v1 tags: ", \%ret ) 
        if ( $opt_verbose ) ;
    return \%ret ;
    }

# v2 only
sub set_id3tags
    {
    my ($fn, $tags) = @_ ;
    my $opt = "" ;

    print_data("Set tags for $fn to ", $tags)
        if ( $opt_verbose ) ;

    foreach my $k (keys %$tags)
        {
        my $v = $tags -> {$k} ;
        $v =~ s/'/\\'/g ;
        $opt .= "--$k '$v' ";
        }

    my $cmds = "/usr/bin/id3v2 -s '$fn'" ;
    system($cmds) 
      if ( ! $opt_sim ) ;

    my $cmd = "/usr/bin/id3v2 -2 $opt '$fn'" ;
    print STDERR "$cmd\n" 
        if ( $opt_verbose ) ;
    return 
        if ( $opt_sim ) ;

# filename must be utf-8, tags must be latin1 .. ARGH!
    open my $id3, "|-:", "/bin/bash"
        or die "cannot open bash: $!";
    print $id3 $cmd ;
    close ($id3)
        or die "FAILED: '$cmd'" ;
    }

binmode(STDOUT, ":utf-8") ;

GetOptions (
    "force|f"       => \$opt_force,
    "help|h"        => \&usage,
    "sim|s"         => \$opt_sim,
    "verbose|v!"    => \$opt_verbose,
            ) ;

if ( 0 )
    {
    my @e = Encode->encodings() ;
    print_data( "Encodings:", \@e ) ;
    }
print_data("Options: F-$opt_force S-$opt_sim") 
    if ($opt_verbose) ;

my $artistdbfn = $ENV{HOME} . "/.artistdb" ;

my ($artists, $mappings) = load_db($artistdbfn) ;

my $glob = shift || '*.mp3' ;
my @music = glob $glob ;

foreach my $mp3filename ( @music ) 
    {
    my $tags = get_id3tags($mp3filename);
    # print Dumper($mp3filename, $tags);
    if ( $opt_force || (2 > keys %$tags) )
        {
        my ( $a, $t ) = $mp3filename =~ /([^\-]+)\s*[\-‎\–]+([^\-\(\[]+)/ ;
        $a  =~ s/^\s+//g ;
        $a  =~ s/\s+$//g ;
        $t  =~ s/^\s+//g ;
        $t  =~ s/\s+$//g ;
        print_data("Got '$a'/'$t' from filename $mp3filename")
            if ($opt_verbose) ;
        if ( $a && $t )
            {
            my $ma = map_artist ( $a, $artists ) ; 
            $tags -> {artist} = $ma || $a ;
            $tags -> {song} = $t ;
            set_id3tags($mp3filename, $tags);
            }
        }
    elsif( 2 <= keys %$tags)
        {
        my $a = $tags -> {artist} ;
        my $ma = map_artist ( $a, $artists ) ; 
        if ( $ma ) 
            {
            print_data("Map $a -> $ma for $mp3filename") 
                if ($opt_verbose);
            $tags -> {artist} = $ma ;
            set_id3tags($mp3filename, $tags) ;
            }
        $artists -> {$ma} = 1;
        }
    $artists -> {$tags -> {artist}} = 1;
    }

save_db($artistdbfn, $artists, $mappings)  ;

print "Done.\n";
