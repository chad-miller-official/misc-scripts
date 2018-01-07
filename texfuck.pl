#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;

my $string = $ARGV[0] or die 'Usage: ' . basename( $0 ) . " <string>\n";
   $string =~ s/"|'//g;

my $modified = '';
my $flip     = 0;

foreach( split( //, $string ) )
{
    $modified .= '_' if $flip > 0;
    $modified .= '^' if $flip < 0;
    $modified .= $_;

    $flip = ( ( $flip & 1 ) ^ 1 ) * ( int rand 2 == 0 ? 1 : -1 );
}

$modified =~ s/(_|\^)( |!|\?|\.)/ $2 /g;
$modified =~ s/( |!|\?|\.)(_|\^)/ $1 /g;
$modified =~ s/   / \\; /g;

print "\$\$$modified\$\$\n";

exit 0;
