#!/usr/bin/perl

use strict;
use warnings;

use Config::IniFiles;
use HTML::Parser;
use JSON;
use POSIX qw(strftime);

my $API_AUTH_URL           = 'https://myanimelist.net/v1/oauth2/token';
my $API_BASE_URL           = 'https://api.myanimelist.net/v2';
my $MAL_CONF_LOCATION      = glob '~/.mal_conf.ini';
my $REFRESH_TOKEN_LOCATION = glob '~/.mal_refresh_token';
my $SUBSPLEASE_BASE_URL    = 'https://subsplease.org';

my $CONFIG = Config::IniFiles->new(-file => $MAL_CONF_LOCATION);

sub log_message($) {
    my $message   = shift;
    my $timestamp = strftime('%Y-%m-%dT%H:%M:%SZ', gmtime time);
    print "[$timestamp] $message\n";
    return;
}

sub fetch_subsplease_shows() {
    log_message "Downloading show list from SubsPlease...";

    my $url_list = {};

    local *anchor_handler = sub {
        my $attr = shift;

        if($attr->{title}) {
            (my $href         = $attr->{href}) =~ s/^\///;
             my $title        = $attr->{title};
            $url_list->{$title} = $href;
        }

        return;
    };

    my $anchor_parser = HTML::Parser::->new();
       $anchor_parser->report_tags(qw(a));
       $anchor_parser->handler(start => \&anchor_handler, 'attr');

    my $subsplease_shows_str = `curl -X GET '$SUBSPLEASE_BASE_URL/shows/' -s`;

    $anchor_parser->parse($subsplease_shows_str);

    return $url_list;
}

sub authenticate_and_get_auth() {
    log_message "Authenticating with MyAnimeList...";
    log_message "Reading refresh token on disk...";

    my $refresh_token_fh;

    open($refresh_token_fh, '<', $REFRESH_TOKEN_LOCATION) or die "ERROR: $!\n";
    chomp (my $refresh_token = <$refresh_token_fh>);
    close $refresh_token_fh;

    my %form_data = (
        client_id     => $CONFIG->val('mal', 'client_id'),
        client_secret => $CONFIG->val('mal', 'client_secret'),
        refresh_token => $refresh_token,
        grant_type    => 'refresh_token',
    );

    my $form_data_str        = join('&', map { "$_=$form_data{$_}" } keys %form_data);
    my $refresh_response_str = `curl -X POST '$API_AUTH_URL' -s -H 'Content-Type: application/x-www-form-urlencoded' -d "$form_data_str"`;
    my $refresh_response     = decode_json $refresh_response_str;
    my $token_type           = $refresh_response->{token_type};
    my $access_token         = $refresh_response->{access_token};
       $refresh_token        = $refresh_response->{refresh_token};

    die "ERROR: Authentication failed! Response body: $refresh_response_str\n" unless $access_token;
    log_message "Updating refresh token on disk...";

    open($refresh_token_fh, '>', $REFRESH_TOKEN_LOCATION) or die $!;
    print {$refresh_token_fh} $refresh_token;
    close $refresh_token_fh;

    return "Authorization: $token_type $access_token";
}

sub fetch_watching_list($) {
    my $auth_header = shift;

    log_message "Fetching anime list...";

    my $watching_list_str = `curl -X GET '$API_BASE_URL/users/\@me/animelist?status=watching' -s -H '$auth_header'`;
    my $watching_list     = decode_json $watching_list_str;

    return $watching_list;
}

sub fixup_season_verbiage($) {
    my $title = shift;

    if($title =~ /(([[:digit:]])[a-z]{2} Season$)/) {
        my $season_suffix = $1;
        my $season_number = $2;

        $title =~ s/$season_suffix$//;
        $title .= "S$season_number";
    }

    return $title;
}

sub fetch_anime_urls($$$) {
    my ( $auth_header, $subsplease_url_list, $watching_list ) = @_;
    my %anime_urls;

    WATCH_LIST: foreach my $anime (@{$watching_list->{data}}) {
           $anime = $anime->{node};
        my $title = $anime->{title};

        log_message "Fetching data for '$title'...";

        my $detail_str       = `curl -X GET '$API_BASE_URL/anime/$anime->{id}?fields=alternative_titles' -s -H "$auth_header"`;
        my $detail           = decode_json $detail_str;
        my $alternate_titles = $detail->{alternative_titles}->{synonyms};

        foreach my $title ($title, @$alternate_titles) {
            my $season_corrected_title = fixup_season_verbiage $title ;

            if($subsplease_url_list->{$season_corrected_title}) {
                $anime_urls{$title} = "$SUBSPLEASE_BASE_URL/$subsplease_url_list->{$season_corrected_title}/";
                next WATCH_LIST;
            }
        }

        log_message "ERROR: No SubsPlease URL found for '$title'!";
    }

    return \%anime_urls;
}

sub fetch_anime_sids($) {
    my $anime_urls = shift;

    log_message "Fetching SubsPlease SIDs...";

    my $sid_list = {};

    my $table_parser = HTML::Parser::->new();
       $table_parser->report_tags(qw(table));
       $table_parser->handler(start => \&table_handler, 'attr');

    foreach my $anime_title (keys %$anime_urls) {
        local *table_handler = sub {
            my $attr                     = shift;
               $sid_list->{$anime_title} = $attr->{sid} if $attr->{id} eq 'show-release-table';

            return;
        };

        my $anime_url            = $anime_urls->{$anime_title};
        my $subsplease_shows_str = `curl -X GET $anime_url -s`;

        $table_parser->parse($subsplease_shows_str);

        log_message "ERROR: No SID found for '$anime_title'!" unless $sid_list->{$anime_title};
    }

    return $sid_list;
}

sub fetch_anime_episode_urls($) {
    my $sid_list = shift;
    my %anime_episodes;

    foreach my $anime_title (keys %$sid_list) {
        log_message "Fetching episode torrent URLs for '$anime_title'...";

        my $anime_sid               = $sid_list->{$anime_title};
        my $subsplease_response_str = `curl -X GET '$SUBSPLEASE_BASE_URL/api/?f=show&tz=America/New_York&sid=$anime_sid' -s`;
        my $subsplease_response     = decode_json $subsplease_response_str;
        my $episodes                = $subsplease_response->{episode};

        my $episode_map = {};

        foreach my $episode_title (keys %$episodes) {
            my $episode_data      = $episodes->{$episode_title};
            my $episode_number    = int $episode_data->{episode};
            my @episode_downloads = grep { int $_->{res} == 720 } @{$episode_data->{downloads}};
            my $episode_download  = shift @episode_downloads;

            if(!$episode_download) {
                log_message "ERROR: No torrent URL found for '$anime_title' episode #$episode_number!";
            } else {
                my $episode_url                    = $episode_download->{torrent};
                   $episode_map->{$episode_number} = $episode_url;
            }
        }

        $anime_episodes{$anime_title} = $episode_map;
    }

    return \%anime_episodes;
}

sub download_missing_torrents($) {
    my $anime_episodes = shift;

    log_message "Reading downloaded files...";

    opendir(my $downloads, glob '~/Downloads');
    my @downloaded_files = readdir $downloads;
    closedir $downloads;

    @downloaded_files = grep { /\[SubsPlease\].+[.]mkv$/ } @downloaded_files;

    foreach my $anime_title (keys %$anime_episodes) {
        my %episode_map     = %{$anime_episodes->{$anime_title}};
        my $has_new_episode = 0;

        foreach my $episode_number (keys %episode_map) {
            my $episode_url              = $episode_map{$episode_number};
            my $episode_number_with_zero = $episode_number < 10 ? "0$episode_number" : $episode_number;
            my $season_corrected_title   = fixup_season_verbiage $anime_title;
            my @matching_files           = grep { /$season_corrected_title - $episode_number_with_zero/ } @downloaded_files;

            if(!@matching_files) {
                log_message "Downloading '$anime_title' episode #$episode_number to Watch directory...";

                $has_new_episode = 1;
                system "wget $episode_url -O \"\$HOME/Watch/$season_corrected_title - $episode_number.torrent\" --no-check-certificate";
            }
        }

        log_message "No new episodes of '$anime_title' to download!" unless $has_new_episode;
    }
}

my $subsplease_url_list = fetch_subsplease_shows();
my $auth_header         = authenticate_and_get_auth();
my $watching_list       = fetch_watching_list $auth_header;
my $anime_urls          = fetch_anime_urls($auth_header, $subsplease_url_list, $watching_list);
my $sid_list            = fetch_anime_sids $anime_urls;
my $anime_episodes      = fetch_anime_episode_urls $sid_list;

download_missing_torrents($anime_episodes);

log_message "Done!";
exit 0;
