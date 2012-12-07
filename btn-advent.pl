#!/usr/bin/perl
use strict;
use warnings;
use File::Slurp;
use WWW::Curl::Easy;
use POSIX qw(strftime);

# Time interval in seconds
my $INTERVAL = 5 * 60;

# Read cookies (for logged in BTN session) from files
my $PHPSESSID = read_file('PHPSESSID.txt') or die;
my $CFDUID = read_file('__cfduid.txt') or die;
my $KEEPLOGGED = read_file('keeplogged.txt') or die;

# Initialize curl stuff
my $curl = WWW::Curl::Easy->new;
my $response_body;

$curl->setopt(CURLOPT_HEADER,1);
$curl->setopt(CURLOPT_URL, 'https://broadcasthe.net/advent.php?action=claimprize');
$curl->setopt(CURLOPT_COOKIE, "PHPSESSID=$PHPSESSID; __cfduid=$CFDUID; keeplogged=$KEEPLOGGED");
$curl->setopt(CURLOPT_WRITEDATA, \$response_body);

# Subroutine for logging
sub verbose
{
	print strftime("[%F %T] ", localtime());
	print @_;
}

print "Time interval is $INTERVAL seconds...\n";

# Main infinite loop
for (;;) {
	$response_body = "";
	my $retcode = $curl->perform();

	if ($retcode == 0) {
		if ($response_body =~ /<b>(\d+d \d+h \d+m \d+s)<\/b>/) {
			verbose("Time left until next claim: $1\n");
		} else {
			verbose("Yay, claimed a prize!\n");
		}
	} else {
		verbose("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
	}

	# Now we gotta sleep for a bit...
	sleep($INTERVAL);
}
