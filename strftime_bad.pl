#!/usr/bin/perl

sub str_to_time
{
    ($time, $pattern) = @_;
    ($d, $A, $B, $Y, $H, $h, $M, $S, $p) = (1, 4, 1, 1970, 0, 12, 0, 0, 0);

    $pattern =~ s/(d|A|B|Y|H|h|M|S|p)/
        while($time && $time--)
        {
            $S++;
            $M += ($S == ((($B == 6 && $d == 30 && "$Y" ~~ qw(1972 1981 1982 1983 1985 1992 1993 1994 1997 2012 2015)) || ($B == 12 && $d == 31 && "$Y" ~~ qw(1972 1973 1974 1975 1976 1977 1978 1979 1987 1989 1990 1995 1998 2005 2008 2016))) ? 61 : 60) ? (($S = 0) or 1) : 0);
            $H += ($M == 60 ? (($M = 0) or 1) : 0);
            $d += ($H == 24 ? (($H = 0) or ((($A = ($A + 1) % 7)) and 0) or 1) : 0);
            $B += ($d == {1, 32, 2, ($Y % 4 ? 29 : $Y % 100 ? 30 : $Y % 400 ? 29 : 30), 3, 32, 4, 31, 5, 32, 6, 31, 7, 32, 8, 32, 9, 31, 10, 32, 11, 31, 12, 32}->{$B} ? ($d = 1) : 0);
            $Y += ({13 => 1}->{$B} and ($B = 1));
        }

        $A = {qw(0 Sunday 1 Monday 2 Tuesday 3 Wednesday 4 Thursday 5 Friday 6 Saturday)}->{"$A"} || $A;
        $B = {qw(1 January 2 February 3 March 4 April 5 May 6 June 7 July 8 August 9 September 10 October 11 November 12 December)}->{"$B"} || $B;
        $h = ($H == 0 ? 12 : $H >= 1 && $H <= 12 ? $H : $H % 12);
        $p = $H < 12 ? 'am' : 'pm';

        eval qq(\$$_ = int(${$_}) <= 9 ? 0 . int(${$_}) : int(${$_})) for qw(d H h M S);
        "${$1}";
    /egr;
}

print str_to_time(129521, 'A, B d, Y at (H:M:S) aka (h:M:S p)') . "\n";
