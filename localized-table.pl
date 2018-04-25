#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;

my $file = $ARGV[0] or die 'Usage: ' . basename( $0 ) . " <filename>\n";
my $file_contents = '';

open( my $fileh, '<', $file ) or die "Could not open $file: $!\n";

my $formatted = <<'TXT';
{| class="wikitable" style="margin:auto"
! REFERENCE || LANG_ENGLISH || Notes
TXT

my @references     = ();
my @lang_englishes = ();

while( my $line = <$fileh> )
{
    if( $line =~ /^REFERENCE\s+(.+)$/ )
    {
        push( @references, $1 );
    }
    elsif( $line =~ /^LANG_ENGLISH\s+"(.+)"$/ )
    {
        push( @lang_englishes, $1 );
    }
}

my $lim = ( scalar @references ) - 1;

for( 0 .. $lim )
{
    $formatted .= <<"TXT";
|-
| $references[$_] || $lang_englishes[$_] ||
TXT
}

close $fileh;

$formatted .= <<"TXT";
|}
TXT

print $formatted;

exit 0;
