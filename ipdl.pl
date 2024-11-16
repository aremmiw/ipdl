#!/usr/bin/env perl
use strict;
use warnings;

use Getopt::Long;
use LWP::Simple;
use Regexp::Common qw(URI);

my $output = "";
my $help;

GetOptions ("output=s" => \$output,
	    "help"     => \$help,
	    ) || die 'Error: invalid options';

print_help() if $help;

die 'Error: No output given!' unless (length $output); #TODO: check that path is writable

my @files;
my $linkcounter = 0;

foreach (@ARGV) {
	unless (check_url($_) || check_file_read($_)) {
		die "Error: Invalid file/url: $_";
	}
}

open(my $outfh, '>', $output) || die $!;

my %seenips;
# $ipv4_regex matches any IPv4 address or IPv4 CIDR block
my $ipv4_regex = '((25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})[.](25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{1,2})(\/(3[0-2]|[12]?[0-9]))?)';
# $ipv6_regex matches any IPv6 address or IPv6 CIDR block
#my $ipv6_regex =

foreach my $file (@files) {
	open(my $ifileh, '<', $file) || die $!;
	while (<$ifileh>) {
		chomp;
		if (($_ =~ /$ipv4_regex/) && !$seenips{$1}++) {
			print $outfh "$1\n";
		}
	}
	close $ifileh;
}

close $outfh || warn 'Closing output failed!';

sub check_url {
	shift;
	if (/$RE{URI}{HTTP}{-scheme => qr<https?>}/) {
		my $temppath = "/tmp/ipdl$linkcounter.txt";
		my $dl = getstore($_, $temppath);
		if (defined($dl) && $dl == 200) {
			push(@files, $temppath);
			$linkcounter++;
			return 1;
		}
		return 0;
	}
}

sub check_file_read {
	shift;
	if (-e $_ && -r $_) {
		push(@files, $_);
		return 1;
	}
	return 0;
}

sub print_help {
	print <<~'EOF';
	ipdl - Merge lists of IPs (and HTTP(S) URLs of lists) to a single IP list.

	Usage: ipdl.pl [OPTIONS]... [FILES/URLs]...
	 --output, -o [FILE]	file to output merged list to. (REQUIRED)
	 --help, -h		print this help

	Each FILE/URL must be a text file or HTTP(S) link to a text file containing
	 a list of IPv4/IPv6 addresses or CIDR blocks.
	EOF
	exit;
}
