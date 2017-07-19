#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use File::Basename;

binmode( STDOUT, ':utf8' );

my %repl_map = (
    'a' => [ 'æ', 'ä', 'å' ],
    'e' => 'ë',
    'i' => 'ï',
    'o' => [ 'œ', 'ö', 'ø' ],
    'u' => 'ü',
    'y' => 'ÿ',
    'A' => [ 'Æ', 'Ä', 'Å' ],
    'E' => 'Ë',
    'I' => 'Ï',
    'O' => [ 'Œ', 'Ö', 'Ø' ],
    'U' => 'Ü',
    'Y' => 'Ÿ',
);

my $str = $ARGV[0] or die 'Usage: ' . basename( $0 ) . " <string>\n";

while( my ( $letter, $repl ) = each %repl_map )
{
    $repl = $repl->[int rand scalar @$repl] if ref $repl eq 'ARRAY';
    $str  =~ s/$letter/$repl/g;
}

print "$str\n";
exit 0;
