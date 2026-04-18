#!/usr/bin/env perl

use v5.42;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';
binmode STDIN, ':encoding(UTF-8)';
use Furl;
use Getopt::Long;
use Pod::Usage;


my $help = 0;
my $proxy_list = 'https://cdn.jsdelivr.net/gh/proxifly/free-proxy-list@main/proxies/all/data.txt';
my $timeout = 1;


GetOptions( 'help|?' => \$help
          , 'link-to-proxy|p=s' => \$proxy_list
          , 'timeout|t=i' => \$timeout);
pod2usage(1) if $help;
pod2usage(2) unless $ARGV[0];


my $furl = Furl->new(timeout => 5);
my @proxy_list = split( /\n/, $furl->get($proxy_list)->content );

my @link_list = @ARGV;


my %proxy_hash;
my $counter = @proxy_list;
foreach my $proxy (@proxy_list)
{
    say $counter--, '..';
    # my $parsed_proxy = $proxy =~
    #         s/
    #         ^.* server=(?<server> [^&]+) .*$

    #         /$+{server}/xr;

    my $parsed_proxy = $proxy;

    foreach my $link (@link_list)
    {
        # say $parsed_proxy;
        open my $fh, '-|',
          "curl -s -L -o /dev/null --write-out '\%{http_code} \%{time_total}' --proxy $parsed_proxy -m $timeout $link";

        while (my $line = <$fh>)
        {
            if ($line =~ /^(?<http_code>\d{3}) (?<time>[\d.]+)/
            and $+{http_code} == 200 and $+{time} < $timeout)
            {
                say "$+{time} - $proxy";
                $proxy_hash{$proxy} .= $+{time};
            }
        }
    }
}

foreach (sort {$proxy_hash{$a} <=> $proxy_hash{$b}} keys %proxy_hash) {
    say "$proxy_hash{$_} - $_";
}

__END__

=head1 SYNOPSIS

main.pl [options...] <urls...>

=head1 OPTIONS

=over 4

=item B<-h, --help>

Prints this message.

=item B<-p, --link-to-proxy> <url>

Link to a site from that to fetch proxy server links.

Default is: https://cdn.jsdelivr.net/gh/proxifly/free-proxy-list@main/proxies/all/data.txt

=item B<-t, --timeout> <seconds>

Max time to wait for a responce before switching to next proxy.

Default is: 1

=back

=cut
