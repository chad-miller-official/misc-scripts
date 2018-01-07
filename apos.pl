#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;

my $string = $ARGV[0] or die 'Usage: ' . basename( $0 ) . " <string>\n";

my %map = (
    'nt' => "n't",
    're' => "'re",
    'm'  => "'m",
    'll' => "'ll",
    'd'  => "'d",
    's'  => "'s",
    've' => "'ve",
);

while( my ( $orig, $repl ) = each %map )
{
    my $orig_uc = uc $orig;
    my $repl_uc = uc $repl;

    $string =~ s/$orig/$repl/g;
    $string =~ s/$orig_uc/$repl_uc/g;
}

$string =~ s/ '/ /g;
$string =~ s/'{2,}/'/g;

print "$string\n";
exit 0;
