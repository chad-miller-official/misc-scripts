#!/usr/bin/perl

use strict;
use warnings;

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

my $thread      = decode_json( $json );
my $thread_name = defined $thread->{posts}->[0]->{sub}
                ? decode_entities( $thread->{posts}->[0]->{sub} )
                : "$thread_op";

my $save_location = @save_location
                  ? glob join( ' ', @save_location )
                  : '.';

$save_location .= "/$thread_name";

if( length( $thread_name ) > 24 )
{
    $thread_name = substr( $thread_name, 0, 21 );
    $thread_name .= '...';
}

my $timer_max = scalar @{$thread->{posts}};

foreach my $post ( @{$thread->{posts}} )
{
    next unless $post->{tim};

    my $filename = $post->{tim}      . $post->{ext};
    my $realname = $post->{filename} . $post->{ext};

    next if -e "$save_location/$realname";

    my $ff  = File::Fetch->new( uri => "http://i.4cdn.org/$board/$filename" );
    my $uri = $ff->fetch( to => $save_location );

    my $rename_uri = $uri;
       $rename_uri =~ s/^(.+)\/(.+)$/$1\/$realname/;

    rename( $uri, $rename_uri );
}

exit 0;
