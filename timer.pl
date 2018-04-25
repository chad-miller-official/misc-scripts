#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;

my $use_msg = 'Usage: ' . basename( $0 ) . " <message> <mm:ss>\n";
my $message = $ARGV[0] or die $use_msg;
my $time    = $ARGV[1] or die $use_msg;

die "Unrecognized time format. Must be one of: <mm:ss|:ss|s>\n" if $time !~ m/^(\d+)?:?(\d+)$/;

my $pid = fork;

if( !$pid )
{
    my $seconds = 0;

    if( $time =~ m/^:(\d+)$/ ) {
        $seconds = int $1;
    } elsif( $time =~ m/^(\d+):(\d+)$/ ) {
        $seconds = ( int( $1 ) * 60 ) + int( $2 );
    } else {
        $seconds = int $time;
    }

    sleep $seconds;

    `notify-send Timer "$message"`;
}

exit 0;
