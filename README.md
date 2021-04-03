## Regex Filters for Pi-hole
This is a custom regex filter file for use with Pi-hole v4+ (FTLDNS).

The purpose of this list is to compliment your existing blocklists using powerful regular expressions that can cover a very broad range of domains. A single regular expression can block thousands of 'bad' domains, and can even accommodate for domains following specific patterns that may not even (yet) exist on standard blocklists.

There are also some optional regex filters separate to the main installer that can be added manually (if desired):
* [Facebook](https://github.com/clayauld/pihole-regex/tree/master/social)
* [Miscellaneous Items](https://github.com/clayauld/pihole-regex/tree/master/miscellaneous)
* [User Suggested](https://github.com/clayauld/pihole-regex/tree/master/user%20suggested)

All commands will need to be entered via Terminal (PuTTY or your SSH client of choice) after logging in and [**Python 3.6+**](https://github.com/clayauld/pihole-regex/issues/16) is required.

### Add to Pi-Hole
```
curl -sSl https://raw.githubusercontent.com/clayauld/pihole-regex/master/install.py | sudo python3
```

### Remove from Pi-Hole
```
curl -sSl https://raw.githubusercontent.com/clayauld/pihole-regex/master/uninstall.py | sudo python3
```

### False Positives ###
Due to the restrictive nature of these regexps, you may encounter a small number of false positives for domain names that are similar to ad-serving / tracking domains. I have created a [whitelist file](https://raw.githubusercontent.com/clayauld/pihole-regex/master/whitelist.list) to populate with user reported false positives. Please note that this file is not currently referenced during installation and is intended to be used only if you experience issues or for reference purposes.

### Keep regexps up-to-date with cron (optional)
The following instructions will create a cron job to run every monday at 02:30 (adjust the time to suit your needs):

1. Edit the root user's crontab (`sudo crontab -u root -e`)

2. Enter the following:
```
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
30 2 * * 1 /usr/bin/curl -sSl https://raw.githubusercontent.com/clayauld/pihole-regex/master/install.py | /usr/bin/python3
35 2 * * 1 /usr/bin/curl -sSl https://raw.githubusercontent.com/clayauld/pihole-regex/master/install_whitelist.sh | /bin/bash
```
3. Save changes

#### Removing the manually created cron job
If this script is the only thing you've added to the root user's crontab, you can run:

`sudo crontab -u root -r`

Otherwise, run:

`sudo crontab -u root -e` and remove the three lines listed above in the install instructions.
