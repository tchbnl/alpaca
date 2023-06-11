Alpaca parses the Apache access logs for a domain and shows some useful (imo) info:
```
# alpaca notarealdomain.com
Fetching stats for notarealdomain.com...
Log: /usr/local/apache/domlogs/notarealdomain.com.log

🎯 Hits (09/Jun/2023):
     23: 2

🎯 Hits (10/Jun/2023):
     00: 213 01: 11

🎯 Hits (11/Jun/2023):
     01: 522

💬 Responses:
     200: 718 404: 30

🔗 URIs:
     718 200 GET /
      27 404 GET /hello.php
       2 404 GET /favicon.ico
       1 404 GET /test.txt

🧔 User Agents:
     518 "2009 Ford Focus Infotainment System"
     172 "curl/7.76.1"
      51 "Mozilla/3.0 (compatible; NetPositive/2.1.1; BeOS)"
       4 "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/114.0"
       3 "Mozilla/5.0 (BeOS; U; BeOS BePC; en-US; rv:1.8.1.6) Gecko/20070731 BonEcho/2.0.0.6"

🌐 IPs:
     518 23.235.204.195 vps90245.inmotionhosting.com
     172 5.161.125.23   No PTR record found
      58 71.126.246.227 pool-71-126-246-227.bstnma.fios.verizon.net
```

You can update the path to the domlogs and what to look for near the top of the file:
```bash
DOMLOGS="/usr/local/apache/domlogs"
LOGFILE="$(find "${DOMLOGS}" -type f -iname "${1}.log")"
```

Results are limited to the last 24 hours. Eventually I'll add support for specifying a different date range, but for a v0.1, this is pretty complete as it is. I also still need to fix the massive line length for hits per hour. I swear I'll do it soon.

Note that this assumes a default Apache log format. If yours has been edited, the awk positions will need to be swapped around a bit.
