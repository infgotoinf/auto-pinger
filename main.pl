#!/usr/bin/env perl

use v5.42;
use utf8;
use Furl;


my $link = 'https://raw.githubusercontent.com/SoliSpirit/mtproto/master/all_proxies.txt';

my $wait = 2;
my $furl = Furl->new(timeout => $wait);
my @proxy_list = split( /\n/, $furl->get($link)->content );

my %proxy_hash;
foreach my $proxy (@proxy_list) {
    my $parsed_proxy = $proxy =~
            s/
            ^.* server=(?<server> [^&]+) .*$

            /$+{server}/xr;

    open $proxy_hash{$parsed_proxy}, '-|', "ping -w $wait $parsed_proxy";

    # say $parsed_proxy;
    # say $proxy_hash{$parsed_proxy};
}

do {
    say "$wait..";
    sleep 1;
    --$wait;
} while ($wait > 0);

foreach my $proxy (keys %proxy_hash) {
    # foreach ($proxy_hash{$proxy}) {
    #     say $proxy;
    # }
    # say $proxy;
    say $proxy_hash{$proxy};
    close $proxy;
}
