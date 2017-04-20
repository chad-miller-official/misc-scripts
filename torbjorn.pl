#!/usr/bin/perl

use utf8;

binmode( STDOUT, ':utf8' );

%repl_map = (
    'a' => ( 'æ', 'ä', 'å' ),
    'e' => 'ë',
    'i' => 'ï',
    'o' => ( 'œ', 'ö', 'ø' ),
    'u' => 'ü',
    'y' => 'ÿ',
    'A' => ( 'Æ', 'Ä', 'Å' ),
    'E' => 'Ë',
    'I' => 'Ï',
    'O' => ( 'Œ', 'Ö', 'Ø' ),
    'U' => 'Ÿ',
);

$str = $ARGV[0] or die "Usage: $0 <string>\n";

while( ( $letter, $repl ) = each %repl_map )
{
    $repl = $repl[int rand scalar @$repl] if ref $repl eq 'ARRAY';
    $str  =~ s/$letter/$repl/g;
}

print "$str\n";
exit 0;
