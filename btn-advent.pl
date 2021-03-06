#!/usr/bin/perl

#
# Copyright (C) 2012-2014  stfn <stfnmd@gmail.com>
# https://github.com/stfnm/btn-advent
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use strict;
use warnings;
use Getopt::Long;
use WWW::Curl::Easy;
use POSIX qw(strftime);

# Options
my $OPT_COOKIES = "cookies.txt";
my $OPT_QUIET = 0;
my $OPT_LOGIN = "";
my $OPT_USERAGENT = "";
my $OPT_PUSHOVER = "";
my $OPT_DEBUG = 0;

GetOptions(
	'help' => \&help,
	'login=s' => \$OPT_LOGIN,
	'cookies=s' => \$OPT_COOKIES,
	'useragent=s' => \$OPT_USERAGENT,
	'pushover=s' => \$OPT_PUSHOVER,
	'quiet' => \$OPT_QUIET,
	'debug' => \$OPT_DEBUG,
);

main();

sub help
{
	print<<__EOH__;
Usage of $0:

	-h, --help
		Print help message and quit.
	-l, --login=<username:password>
		Perform login with the provided username and password.
	-c, --cookies=<file name>
		Cookies file in Netscape HTTP Cookie File format. (default: cookies.txt)
	-u, --useragent=<user agent string>
		User agent string to use.
	-p, --pushover=<token:user>
		Send notification using pushover.net when you got a new prize.
	-q, --quiet
		Turn off any output.
	-d, --debug
		Enable debug output.

__EOH__
	exit;
}

sub verbose
{
	return if ($OPT_QUIET);
	print strftime("[%F %T] ", localtime());
	print @_;
}

sub url_escape($)
{
	my $toencode = $_[0];
	return undef unless (defined($toencode));
	utf8::encode($toencode) if (utf8::is_utf8($toencode));
	$toencode =~ s/([^a-zA-Z0-9_.~-])/uc sprintf("%%%02x",ord($1))/eg;
	return $toencode;
}

sub notify($)
{
	my $msg = $_[0];

	if ($OPT_PUSHOVER =~ /(.+):(.+)/) {
		my ($token, $user) = ($1, $2);
		notify_pushover($token, $user, $msg, "btn-advent", "", "");
	}
}

# https://pushover.net/api
sub notify_pushover($$$$$$)
{
	my ($token, $user, $message, $title, $priority, $sound) = @_;

	# Required API arguments
	my @post = (
		"token=" . url_escape($token),
		"user=" . url_escape($user),
		"message=" . url_escape($message),
	);

	# Optional API arguments
	push(@post, "title=" . url_escape($title)) if ($title && length($title) > 0);
	push(@post, "priority=" . url_escape($priority)) if ($priority && length($priority) > 0);
	push(@post, "sound=" . url_escape($sound)) if ($sound && length($sound) > 0);

	my $postfields = join(";", @post);

	# Send HTTP POST
	my $curl = WWW::Curl::Easy->new;
	my $response_body;

	$curl->setopt(CURLOPT_HEADER, 1);
	$curl->setopt(CURLOPT_URL, 'https://api.pushover.net/1/messages.json');
	$curl->setopt(CURLOPT_WRITEDATA, \$response_body);
	$curl->setopt(CURLOPT_POST, 1);
	$curl->setopt(CURLOPT_POSTFIELDS, $postfields);

	$curl->perform();
}

sub btn_login($$)
{
	my ($user, $password) = @_;
	my $curl = WWW::Curl::Easy->new;
	my $response_body;

	$curl->setopt(CURLOPT_HEADER, 1);
	$curl->setopt(CURLOPT_URL, 'https://broadcasthe.net/login.php');
	$curl->setopt(CURLOPT_COOKIEFILE, $OPT_COOKIES);
	$curl->setopt(CURLOPT_COOKIEJAR, $OPT_COOKIES);
	$curl->setopt(CURLOPT_WRITEDATA, \$response_body);
	$curl->setopt(CURLOPT_USERAGENT, $OPT_USERAGENT) if (length($OPT_USERAGENT) > 0);
	$curl->setopt(CURLOPT_POST, 1);
	$curl->setopt(CURLOPT_POSTFIELDS, "username=" . url_escape($user) . "&password=" . url_escape($password) . "&keeplogged=1");

	$curl->perform();
}

sub btn_advent
{
	my $curl = WWW::Curl::Easy->new;
	my $response_body;
	my $time = -1;

	$curl->setopt(CURLOPT_HEADER, 1);
	$curl->setopt(CURLOPT_URL, 'https://broadcasthe.net/advent.php?action=claimprize');
	$curl->setopt(CURLOPT_COOKIEFILE, $OPT_COOKIES);
	$curl->setopt(CURLOPT_COOKIEJAR, $OPT_COOKIES);
	$curl->setopt(CURLOPT_WRITEDATA, \$response_body);
	$curl->setopt(CURLOPT_FOLLOWLOCATION, 1);
	$curl->setopt(CURLOPT_USERAGENT, $OPT_USERAGENT) if (length($OPT_USERAGENT) > 0);

	my $retcode = $curl->perform();

	if ($retcode == 0 && $response_body =~ /<b>(\d+d \d+h \d+m \d+s)<\/b>/) {
		my $timestr = $1;
		verbose("Time left until next claim: $timestr\n");

		if ($timestr =~ /(\d+)d (\d+)h (\d+)m (\d+)s/) {
			$time = $1 * 24 * 60 * 60;
			$time += $2 * 60 * 60;
			$time += $3 * 60;
			$time += $4;
		}
	} elsif ($retcode == 0 && $response_body =~ /You have received the following prize:.*?<h1>(.*?)<\/h1>/) {
		my $msg = "Yay! You got the following prize: $1\n";
		verbose($msg);
		notify($msg);
		$time = 0;
	} elsif ($retcode == 0 && $response_body =~ /Click.+to claim them!/) {
		verbose("Sorry, the advent calendar is over. You may claim your gold stars if you have any!\n");
		$time = -1;
	} else {
		verbose("Oops, something went wrong this time. Maybe the website is down?\n");
		$time = 5 * 60;

		print $response_body if ($OPT_DEBUG);
	}

	return $time;
}

sub main
{
	if ($OPT_LOGIN =~ /^(.+):(.+)$/) {
		verbose("Logging in...\n");
		btn_login($1, $2);
	}

	for (;;) {
		my $time = btn_advent();

		if ($time > 0) {
			verbose("Sleeping for $time seconds...\n");
			sleep($time);
		} elsif ($time == 0) {
			next;
		} else {
			last;
		}
	}
}
