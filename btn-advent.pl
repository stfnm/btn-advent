#!/usr/bin/perl

#
# Copyright (C) 2012  stfn <stfnmd@gmail.com>
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
use WWW::Curl::Easy;
use POSIX qw(strftime);

# Time interval in seconds
my $INTERVAL = 5 * 60;

# Cookies file
my $COOKIES = "cookies.txt";

# Subroutine for logging
sub verbose
{
	print strftime("[%F %T] ", localtime());
	print @_;
}

print "Time interval is $INTERVAL seconds...\n";

# Main infinite loop
for (;;) {
	# Curl scope
	{
		my $curl = WWW::Curl::Easy->new;
		my $response_body;

		$curl->setopt(CURLOPT_HEADER,1);
		$curl->setopt(CURLOPT_URL, 'https://broadcasthe.net/advent.php?action=claimprize');
		$curl->setopt(CURLOPT_COOKIEFILE, $COOKIES);
		$curl->setopt(CURLOPT_COOKIEJAR, $COOKIES);
		$curl->setopt(CURLOPT_WRITEDATA, \$response_body);

		my $retcode = $curl->perform();

		if ($retcode == 0) {
			if ($response_body =~ /<b>(\d+d \d+h \d+m \d+s)<\/b>/) {
				verbose("Time left until next claim: $1\n");
			} elsif ($response_body =~ /You have received the following prize:.*?<h1>(.*?)<\/h1>/) {
				verbose("Yay, you got the following prize: $1\n");
			} else {
				verbose("$response_body\n");
			}
		} else {
			verbose("An error happened: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
		}
	}

	# Now we gotta sleep for a bit...
	sleep($INTERVAL);
}
