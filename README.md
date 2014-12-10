# btn-advent
A simple perl script which checks the BTN advent calendar for you.

You can either have the script do the login for you or provide existing cookies yourself in Netscape HTTP Cookie File format.

To retrieve your cookies the following browser addons might be helpful:
* [Chrome: cookie.txt export](https://chrome.google.com/webstore/detail/cookietxt-export/lopabhfecdfhgogdbojmaicoicjekelh)
* [Firefox: Export Cookies](https://addons.mozilla.org/de/firefox/addon/export-cookies/)

## Dependencies
* [WWW::Curl](http://search.cpan.org/~szbalint/WWW-Curl/lib/WWW/Curl.pm)

## Usage Example
```
$ ./btn-advent.pl --login username:password
```
or if you already have your cookies:
```
$ ./btn-advent.pl --cookies cookies.txt
```

## Troubleshooting
Unfortunately due to CloudFlare's protection stuff the "--login" parameter doesn't work anymore.
You will have to provide existing cookies from your browser. Please make sure you also have "keep logged in" enabled.

Moreover it seems that CloudFlare sticks the cookie to your IP address as well as your user agent string,
so you will have to take care of that too by using the same IP and supplying the same user agent string as you used with your browser.
You can find out about it for example by visiting http://whatsmyuseragent.com/ and supply it to the script like this:
```
$ ./btn-advent.pl --cookies cookies.txt --useragent "Mozilla/5.0 (X11; Linux x86_64; rv:34.0) Gecko/20100101 Firefox/34.0"
```
Also note that CloudFlare cookies only last 7 days.

## License
Copyright (C) 2012-2014  stfn <stfnmd@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
