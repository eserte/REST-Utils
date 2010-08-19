#!/usr/bin/perl

# Test HTTP tunneling
use strict;
use warnings;
use Test::More tests => 9;
use CGI;
use Test::WWW::Mechanize::CGI;
use REST::Utils qw( media_type );

my $mech = Test::WWW::Mechanize::CGI->new;
$mech->cgi( sub {
    my $q = CGI->new;    

    my $preferred = media_type($q, 
        ['application/xhtml+xml', 'text/html', 'text/plain', '*/*']);
    print $q->header(-type => $preferred);
});

$mech->add_header(Accept => 'application/xhtml+xml;q=1.0, text/html;q=0.9, text/plain;q=0.8, */*;q=0.1');

$mech->get('http://localhost/');
is($mech->content_type, 'application/xhtml+xml', 'GET preferred content type');

$mech->add_header(Accept => 'application/xhtml+xml;q=0.9, text/html;q=0.8, text/plain;q=1.0, */*;q=0.1');

$mech->get('http://localhost/');
is($mech->content_type, 'text/plain', 'GET preferred content type (not in order)');

$mech->add_header(Accept => 'image/gif;q=1.0');

$mech->get('http://localhost/');
is($mech->content_type, 'text/html', 'GET preferred content type (unusable media type)');

$mech->add_header(Accept => 'application/xhtml+xml;q=1.0, text/html;q=0.9, text/plain;q=0.8, */*;q=0.1');

$mech->head('http://localhost/');
is($mech->content_type, 'application/xhtml+xml', 'HEAD preferred content type');

$mech->post('http://localhost/');
is($mech->content_type, 'text/html', 'POST preferred content type (with Accept)');

$mech->put('http://localhost/');
is($mech->content_type, 'text/html', 'PUT preferred content type (with Accept)');

$mech->post('http://localhost/', Content_Type => 'text/plain');
is($mech->content_type, 'text/plain', 'POST preferred content type (with Content-Type)');

$mech->put('http://localhost/', Content_Type => 'text/plain');
is($mech->content_type, 'text/plain', 'PUT preferred content type (with Content-Type');

$mech->post('http://localhost/', Content_Type => 'text/plain', 'X-HTTP-Method-Override' => 'DELETE');
is($mech->content_type, 'text/html', 'no content negotiation with DELETE');

