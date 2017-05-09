#!/usr/bin/perl

use strict;
use warnings;

use File::Fetch;
use JSON;
use REST::Client;
use Term::ProgressBar;

sub thread_image_dl($$;$)
{
    my ( $board, $thread_op, @save_location ) = @_;
    
    if( !$board || !$thread_op )
    {
        print( "Usage: get images <board> <thread OP> [<save location>]\n" );
        return;
    }
    
    my $save_location = "$thread_op";
       $save_location = glob join( ' ', @save_location ) if @save_location;
    
    $board =~ s/\///g;

    my $client = REST::Client->new();
       $client->GET( "http://a.4cdn.org/$board/thread/$thread_op.json" );

    my $json   = $client->responseContent();
    my $thread = decode_json( $json );

    my $progress = Term::ProgressBar->new( {
        name   => 'Test',
        count  => scalar @{$thread->{posts}},
        remove => 1,
        ETA    => 'linear',
    } );

    $progress->minor( 0 );
    $progress->max_update_rate( 1 );

    my $counter = 0;

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

        $counter++;
        $progress->update( $counter );
    }

    $progress->update( scalar @{$thread->{posts}} );
}

my $commands = {
    'get' => {
        'images' => \&thread_image_dl,
    },
};

# Program main

while( 1 )
{
    print( '> ' );

    my $input  = <STDIN>;
    my @tokens = split( /\s+/, $input );
    
    my $cmd = shift @tokens;
    
    last if( $cmd eq 'exit' );

    my $subcmd = shift @tokens;
    my $opts   = $commands->{$cmd};
    
    if( $opts )
    {
        my $func = defined $subcmd ? $opts->{$subcmd} : undef;
        
        if( $func )
        {
            &$func( @tokens );
        }
        else
        {
            print( "  Valid $cmd commands are:\n" );
            print( "    $_\n" ) for ( keys %$opts );
        }
    }
    else
    {
        print( "  Valid commands are: \n" );
        print( "    $_\n" ) for ( keys %$commands );
        print( "    exit\n" );
    }
}

exit 0;
