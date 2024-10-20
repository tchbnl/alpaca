alpaca is a simple Apache log parser. Give it a domlog and it spits out:

* 🎯 Total hits within the last 24 hours
* 🔗 Top 10 requested URIs
* 🧔 Top 10 user agents
* 🌐 Top 10 IPs (with their PTR record!)

It uses a mix of the `date` and `awk` commands to do the deed. Positions are variables to allow quick edits as needed. Support has been added for `date`'s `-d/--date` feature. Pass something like `alpaca -d '1 hour ago' /path/to/domlog/file` to limit results to the last hour. It is absolutely not robust but it works for me and I am too dumb to figure out how GoAccess works.

A minified version allows for quickly pasting it into a shell without needing to install anything. This is where I reveal it's written in Bash. I'm sorry.

It's probably easy enough to adapt this to Nginx. I might make an Nginx version.
