#!/usr/bin/perl
# Pragmas to ensure code quality
use strict;
use warnings;
use diagnostics;
# Call packages
use HTTP::Request ();
use Encode qw(encode_utf8);
use JSON::MaybeXS qw(encode_json);
use LWP::UserAgent;
use Dotenv;

# Load .env file
my $env = Dotenv->parse('.env');

# Access .env file variables
my $access_token = $ { $env} { ACCESS_TOKEN };
my $calendar_id = $ { $env} { CALENDAR_ID };

# Create new User Agent to call API
my $user_agent = LWP::UserAgent->new();
# Define API endpoint
my $url = 'https://api.nylas.com/events?notify_participants=true';
# Body of the API call
my $data = {title => "Learn Perl with Nylas",
                   when => {start_time => 1675872000, end_time => 1675873800},
                   location => "Blag\'s Den",
                   calendar_id => $calendar_id,
                   participants =>  [{email => "atejada\@gmail.com",
                                             name => "Blag"}]};
# Encode data as JSON
my $encoded_data = encode_utf8(encode_json($data));
# Define API endpoint call
my $request = HTTP::Request->new(POST => $url);
# Pass headers
$request->header('Accept' => 'application/json');
$request->header('Authorization' => "Bearer $access_token");
# Pass body
$request->content($encoded_data);

# Use User Agent to make API endpoint call
my $response = $user_agent->request($request);
# If succesful, then print result
if ($response->is_success) {
    my $message = $response->decoded_content;
    print "Received reply: $message";
}
# Otherwise, show the error message
else {
    print "HTTP POST error code: ", $response->code, "n";
    print "HTTP POST error message: ", $response->message, "n";
}
