#!/usr/bin/env perl

use v5.42;
use utf8;
use Furl;


# my $link = 'https://raw.githubusercontent.com/SoliSpirit/mtproto/master/all_proxies.txt';
my $link = 'https://cdn.jsdelivr.net/gh/proxifly/free-proxy-list@main/proxies/all/data.txt';

my $wait = 1;
my $furl = Furl->new(timeout => 5);
my @proxy_list = split( /\n/, $furl->get($link)->content );
# my @link_list = ('t.me');
# my @link_list = ('www.reaper.fm');
die "First argumen must be a link to ping" unless $ARGV[0];
my @link_list = $ARGV[0];

my %proxy_hash;
my $counter = @proxy_list;
foreach my $proxy (@proxy_list) {
    say $counter--, '..';
    # my $parsed_proxy = $proxy =~
    #         s/
    #         ^.* server=(?<server> [^&]+) .*$

    #         /$+{server}/xr;

    my $parsed_proxy = $proxy;

    foreach my $link (@link_list) {
        # say $parsed_proxy;
        open my $fh, '-|',
        "curl -s -x GET -o /dev/null --write-out '\%{exitcode} \%{time_total}' --proxy $parsed_proxy -m $wait $link";

        while (my $line = <$fh>) {
            if ($line =~ /^(?<exit_code>\d+) (?<time>.+)/) {
                if ($+{exit_code} == 0 && $+{time} < $wait) {
                    say "$line - $proxy";
                    $proxy_hash{$proxy} .= $line;
                }
            }
        }
    }
}

foreach (sort {$proxy_hash{$a} <=> $proxy_hash{$b}} keys %proxy_hash) {
    say "$proxy_hash{$_} - $_" if $proxy_hash{$_} < $wait;
}
