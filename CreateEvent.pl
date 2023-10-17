#!/usr/bin/perl
# Pragmas to ensure code quality
use strict;
use warnings;
use diagnostics;
# Call packages
use Mojo::Headers;
use Dotenv;
use Mojo::UserAgent;
use DateTime;
use Encode qw(encode_utf8);
use JSON::MaybeXS qw(encode_json);

# Load .env file
my $env = Dotenv->parse('.env');

# Access .env file variables
my $api_key_v3 = $ { $env} { API_KEY_V3 };
my $calendar_id = $ { $env} { CALENDAR_ID };
my $guest_email = $ { $env} { GUEST_EMAIL };
my $guest_name = $ { $env} { GUEST_NAME };

# Define API endpoint
my $url = "https://api.us.nylas.com/v3/grants/$calendar_id/events?calendar_id=$calendar_id";

## Body of the API call
(my $sec,my $min,my 	$hour,my $mday,my $mon,my $year,my $wday,my $yday,my $isdst) = localtime();
$year = $year + 1900;
$mon = $mon + 1;

# Build the start and end date and time
my $time_zone = DateTime::TimeZone->new( name => 'local' )->name();
my $start_date = DateTime->new(year => $year, month => $mon, day => $mday, hour => 14, minute => 0, second => 0, time_zone  => $time_zone);
my $end_date = DateTime->new(year => $year, month => $mon, day => $mday, hour => 15, minute => 0, second => 0, time_zone  => $time_zone);

# Build the body
my $data = {title => "Learn Perl with Nylas",
                   when => {start_time => $start_date->epoch, end_time => $end_date->epoch},
                   location => "Blag\'s Den",
                   calendar_id => $calendar_id,
                   participants =>  [{email => $guest_email,
                                             name => $guest_name}]};

## Encode data as JSON
my $encoded_data = encode_utf8(encode_json($data));

# Use User Agent to make API endpoint call
my $ua = Mojo::UserAgent->new;
my $tx = $ua->build_tx(POST => $url);
# Headers
$tx->req->headers->header('Content-Type', 'application/json');
$tx->req->headers->header('Accept', 'application/json');
$tx->req->headers->header("Authorization", "Bearer $api_key_v3");
# Send the request
$tx->req->body($encoded_data);
$ua->start($tx);

# Get the result of the POST operation
my $raw = $tx->res->body;
print $raw;
