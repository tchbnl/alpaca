Alpaca parses the Apache access logs for a domain and shows some useful (imo) info:
```
# alpaca thisdomainwasboughtforme.com
Fetching stats for thisdomainwasboughtforme.com...
Log: /usr/local/apache/domlogs/thisdomainwasboughtforme.com.log

🎯 Hits (13/Jun/2023):
     03: 41  04: 24  05: 26  06: 26  07: 26  08: 41  09: 40  10: 49  11: 33  12: 33  13: 49  14: 53
     15: 32  16: 38  17: 40  18: 50  19: 37  20: 45  21: 30  22: 45  23: 27

🎯 Hits (14/Jun/2023):
     00: 90  01: 38  02: 27

💬 Responses:
     200: 587  404: 352  403: 1

🔗 URIs:
     572  200  HEAD  /
     271  404  POST  /xmlrpc.php
      13  200   GET  /
       8  404   GET  /wp-login.php
       2  404   GET  /wp.php
       2  404   GET  /wp-login.php?action=register
       2  404   GET  /wp-content/plugins/akismat/contents.php
       2  404   GET  /index.php
       2  404   GET  /img/logo.png
       2  404   GET  /img/logo.jpg

🧔 User Agents:
     572  "Webmin"
     108  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36"
      44  "Mozlila/5.0 (Linux; Android 7.0; SM-G892A Bulid/NRD90M; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/60.0.3112.107 Moblie Safari/537.36"
      11  "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.99 Safari/533.4"
       7  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.186 Safari/537.36"
       6  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36"
       6  "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/113.0"
       5  "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.5) Gecko/20041107 Firefox/1.0"
       5  "Mozilla/5.0 (Linux; Android 10; LM-X420) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Mobile Safari/537.36"
       4  "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:50.0) Gecko/20100101 Firefox/50.0"

🌐 IPs:
     572  144.208.64.20   vps92688.inmotionhosting.com
      44  5.161.126.195   static.195.126.161.5.clients.your-server.de
      19  148.72.68.227   227.68.72.148.host.secureserver.net
       8  176.53.85.174   server-176.53.85.174.as42926.net
       6  66.175.44.24    web164c40.carrierzone.com
       5  185.244.39.193  185-244-39-193.hosted-by.phanes.cloud
       4  66.175.44.57    web197c40.carrierzone.com
       4  66.175.44.55    web195c40.carrierzone.com
       4  66.175.44.39    web179c40.carrierzone.com
       4  66.175.44.35    web175c40.carrierzone.com
```

You can update the path to the domlogs and what to look for near the top of the file:
```bash
DOMLOGS="/usr/local/apache/domlogs"
LOGFILE="$(find "${DOMLOGS}" -type f -iname "${1}.log")"
```

Results are limited to the last 24 hours. Eventually I'll add support for specifying a different date range, but for a v0.1, this is pretty complete as it is. I also still need to fix the massive line length for hits per hour. ~~I swear I'll do it soon.~~ I did it!

Note that this assumes a default Apache log format. If yours has been edited, the awk positions will need to be swapped around a bit.

A minified version is available to use directly in the shell.
