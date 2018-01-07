#!/usr/bin/perl

use strict;
use warnings;

use experimental 'smartmatch';

use File::Basename;
use File::Fetch;
use HTML::Entities;
use JSON;
use REST::Client;

my ( $board, $thread_op, @save_location ) = @ARGV;

die 'Usage: ' . basename( $0 ) . " <board> <thread> <save location>\n"
    unless $board && $thread_op && @save_location;

$board =~ s/\///g;

my $rest_client = REST::Client->new();
$rest_client->GET( "http://a.4cdn.org/$board/thread/$thread_op.json" );
my $json = $rest_client->responseContent();

unless( $json )
{
    print "Thread does not exist: /$board/$thread_op\n";
    exit 1;
}

my $thread = decode_json( $json );

my $save_location = @save_location
                  ? glob join( ' ', @save_location )
                  : '.';

$save_location .= "/$thread_op";

my $ignore_file = "$save_location/ignore.txt";
my @ignore_list = ();

if( -e $ignore_file )
{
    open( my $ignore_fh, '<', $ignore_file );

    while( my $ignore_file = <$ignore_fh> )
    {
        chomp $ignore_file;
        push( @ignore_list, $ignore_file );
    }

    close $ignore_fh;
}

foreach my $post ( @{$thread->{posts}} )
{
    next unless $post->{tim};

    my $filename = $post->{tim} . $post->{ext};

    next if -e "$save_location/$filename";
    next if $filename ~~ @ignore_list;

    my $ff  = File::Fetch->new( uri => "http://i.4cdn.org/$board/$filename" );
    my $uri = $ff->fetch( to => $save_location );
}

exit 0;
