#!/usr/bin/perl

use strict;
use warnings;

use File::Fetch;
use JSON;
use REST::Client;

my ( $board, $thread_op, $save_location ) = @ARGV;

die "Usage: $0 <board name> <thread OP> [<save location>]\n" if !$board || !$thread_op;

$board =~ s/\///g;

my $client = REST::Client->new();
   $client->GET( "http://a.4cdn.org/$board/thread/$thread_op.json" );

my $json   = $client->responseContent();
my $thread = decode_json( $json );

$save_location = "$thread_op" if not $save_location;

foreach my $post ( @{$thread->{posts}} )
{
    next unless $post->{tim};

    my $filename = $post->{tim}      . $post->{ext};
    my $realname = $post->{filename} . $post->{ext};

    next if -e "$save_location/$realname";

    print( "Fetching $filename...\n" );

    my $ff  = File::Fetch->new( uri => "http://i.4cdn.org/$board/$filename" );
    my $uri = $ff->fetch( to => $save_location );

    my $rename_uri = $uri;
       $rename_uri =~ s/^(.+)\/(.+)$/$1\/$realname/;

    rename( $uri, $rename_uri );
}

exit 0;
