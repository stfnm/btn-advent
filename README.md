# btn-advent
A simple perl script which checks the BTN advent calendar for you.

The script won't perform any login on its own, so you will have to provide existing cookies yourself in Netscape HTTP Cookie File format.

To retrieve the cookies the following browser addons might be helpful:
* https://chrome.google.com/webstore/detail/cookietxt-export/lopabhfecdfhgogdbojmaicoicjekelh
* https://addons.mozilla.org/de/firefox/addon/export-cookies/

## Dependencies
* [WWW::Curl](http://search.cpan.org/~szbalint/WWW-Curl/lib/WWW/Curl.pm)

## Usage Example
```
$ ./btn-advent.pl --cookies btn.txt
```

## License
Copyright (C) 2012-2013  stfn <stfnmd@gmail.com>

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
