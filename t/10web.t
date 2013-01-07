#!/usr/bin/env perl
# Check usage of the ::WebServer
use warnings;
use strict;

use lib 'lib', '../lib';
use Test::More tests => 16;
use Data::Dumper;

my $id     = 'my-id';
my $secret = 'my-secret';
my $site   = 'http://my-site';

use_ok('Net::OAuth2::Profile::WebServer');
my $auth = Net::OAuth2::Profile::WebServer->new
  ( client_id     => $id
  , client_secret => $secret

  , site                 => $site
  , access_token_url     => "$site/a/ccess_token"
  , authorize_path       => "au/htorize"

  , refresh_token_method => 'PUT'
  , access_token_params  => [ tic => 'tac', toe => 0 ]
  );

isa_ok($auth, 'Net::OAuth2::Profile::WebServer');
is($auth->id, $id);
is($auth->secret, $secret);

is($auth->site,              $site, 'check site_url()');
is($auth->site_url('/b/xyz', a => 1, b => 2), 'http://my-site/b/xyz?a=1&b=2');
my $uri = $auth->site_url('/b/xyz', {a => 1, b => 2}); # param order random
my %qp = $uri->query_form;
cmp_ok(scalar keys %qp, '==', 2, join(';',%qp));
cmp_ok($qp{a}, '==', 1);
cmp_ok($qp{b}, '==', 2);

is($auth->access_token_url,  "$site/a/ccess_token");
is($auth->authorize_url,     "$site/au/htorize");
is($auth->authorize_method,  'POST');
is($auth->refresh_token_method, 'PUT');
is($auth->refresh_token_url, "$site/oauth/refresh_token");

my $atp = $auth->access_token_params
  ( even   => 'more'
  , params => 'here'
  , type   => 'web_server'  # may still be required for 37signals
  );

#warn Dumper $atp;
is_deeply($atp,
 , { params => 'here',
   , even   => 'more',
   , type   => 'web_server',
   , code   => ''
   , grant_type    => 'authorization_code',
   , redirect_uri  => undef,
   , client_secret => 'my-secret',
   , client_id     => 'my-id',
   } );

my $ua = $auth->user_agent;
isa_ok($ua, 'LWP::UserAgent');
