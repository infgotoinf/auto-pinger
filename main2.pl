#!/usr/bin/env perl

use v5.42;
use utf8;
use Furl;


my $link = 'https://raw.githubusercontent.com/SoliSpirit/mtproto/master/all_proxies.txt';

my $wait = 1;
my $furl = Furl->new(timeout => 5);
my @proxy_list = split( /\n/, $furl->get($link)->content );
my @link_list = ('t.me');

my %proxy_hash;
my $counter = @proxy_list;
foreach my $proxy (@proxy_list) {
    say $counter--, '..';
    my $parsed_proxy = $proxy =~
            s/
            ^.* server=(?<server> [^&]+) .*$

            /$+{server}/xr;

    foreach my $link (@link_list) {
        # say $parsed_proxy;
        open my $fh, '-|',
        "curl -s -x GET -o /dev/null --write-out '\%{time_total}' --proxy $parsed_proxy -m $wait $link";
        while (my $line = <$fh>) {
            $proxy_hash{$proxy} .= $line;
        }
    }
}

# sub by_time {
#     if %_ >
# }

foreach (sort {$proxy_hash{$a} <=> $proxy_hash{$b}} keys %proxy_hash) {
    say "$proxy_hash{$_} - $_" if $proxy_hash{$_} < $wait;
}
