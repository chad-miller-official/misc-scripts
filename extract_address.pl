#!/usr/bin/perl

use strict;
use warnings;

use Text::CSV_XS;

my ( $addresses_file ) = @ARGV;

die "Usage: $0 <address file>\n" unless $addresses_file;

open( my $addresses_fh, '<', $addresses_file );

my @recipients;
my $working_recipient = '';

while( my $line = <$addresses_fh> )
{
    chomp $line;

    if( $line )
    {
        $working_recipient .= "$line;";
    }
    else
    {
        push( @recipients, $working_recipient );
        $working_recipient = '';
    }
}

push( @recipients, $working_recipient );
close $addresses_fh;

my @addresses;

foreach my $recipient ( @recipients )
{
    my @recipient_parts = split( /;/, $recipient );

    my $address_line_2  = scalar( @recipient_parts ) == 4
        ? $recipient_parts[2]
        : '';

    my $city_state_zip = $recipient_parts[scalar( @recipient_parts ) - 1];
    my $city           = '';
    my $state          = '';
    my $zip_code       = '';

    if( $city_state_zip =~ m/^(.+),\s+([A-Z]{2})\s+([[:digit:]]{5})$/ )
    {
        $city     = $1;
        $state    = $2;
        $zip_code = $3;
    }

    my $display_name = $recipient_parts[0];
    my $first_name   = '';
    my $last_name    = '';

    if( $display_name =~ m/^([^\s]+)\s+([^\s]+)$/ )
    {
        $display_name = '';
        $first_name   = $1;
        $last_name    = $2;
    }

    push(
        @addresses,
        [
            $first_name,
            $last_name,
            $display_name,
            $recipient_parts[1],
            $address_line_2,
            $city,
            $state,
            $zip_code,
        ],
    );
}

my @header = (
    'First Name',
    'Last Name',
    'Display/Household Name (Smith Family)',
    'Address Line 1',
    'Address Line 2',
    'City',
    'State',
    'Postal Code',
    'Country',
    'Email',
);

my $csv = Text::CSV_XS->new( { binary => 1, auto_diag => 1 } );

$csv->say( \*STDOUT, \@header );
$csv->say( \*STDOUT, $_ ) for @addresses;

exit 0;
