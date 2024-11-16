#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Regexp::Common qw(URI net);
use LWP::Simple;

my $output = "";
my $help;

GetOptions ("output=s" => \$output,
	    "help"     => \$help,
	    ) || die 'Error: invalid options';

print_help() unless (!$help);

die 'Error: No output given!' unless (length $output); #TODO: check that path is writable

my @files;
my $linkcounter = 0;

foreach (@ARGV) {
	unless (check_url($_) || check_file_read($_)) {
		die "Invalid file/url: $_";
	}
}

open(my $outfh, '>', $output) || die $!;

my %seenips;

foreach my $file (@files) {
	open(my $ifileh, '<', $file) || die $!;
	while (<$ifileh>) {
		chomp;
		if ((/$RE{net}{IPv4}{-keep}/ || /$RE{net}{IPv6}{-style => 'HeX'}{-keep}/) && !$seenips{$_}++) {
			print $outfh "$1\n"
		}
	}
	close $ifileh;
}

close $outfh || warn "Closing output failed!";

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
	print 'This is the help...';
	exit;
}
