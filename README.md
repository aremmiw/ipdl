# ipdl

ipdl is a Perl script to merge multiple lists (which can be fetched from HTTP/S URLs) of newline deliminated IP addresses and CIDR blocks into a single list.

It is made in mind for frequently updated IP blacklists such as [SPAMHAUS DROP](https://www.spamhaus.org/blocklists/do-not-route-or-peer/) and [ipsum](https://github.com/stamparm/ipsum).
The output file can be used as-is as part of `pf` firewall tables, and likely other firewalls.

Compatible with *nix systems only: it won't work on Windows.

## dependencies
* Perl
  * [LWP::Simple](https://metacpan.org/pod/LWP::Simple)
  * [Regexp::Common](https://metacpan.org/pod/Regexp::Common)

## usage
```
ipdl - Merge lists of IPs (and HTTP(S) URLs of lists) to a single IP list.

Usage: ipdl.pl [OPTIONS]... [FILES/URLs]...
 --output, -o [FILE]	file to output merged list to. (REQUIRED)
 --help, -h		print this help

Each FILE/URL must be a text file or HTTP(S) link to a text file containing
 a list of IPv4/IPv6 addresses or CIDR blocks.
```
