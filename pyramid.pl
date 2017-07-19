#!/usr/bin/perl

use strict;
use warnings;

use feature 'unicode_strings';

my ( $word, $limit ) = @ARGV or die "Usage: $0 <word> <limit>\n";

foreach my $i ( 1 .. int $limit )
{
    print "$word" x $i;
    print "\n";
}

exit 0;
