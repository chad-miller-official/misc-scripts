#!/usr/bin/perl

use strict;
use warnings;

my @letters = ( ( 65 .. 90 ), ( 97 .. 122 ) );
my $length = int( rand 3 ) + 4;
my $word = '';

for( 0 .. $length ) {
    $word .= chr $letters[int rand scalar @letters];
}

print "$word\n";
exit 0;
