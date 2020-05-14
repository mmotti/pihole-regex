## Regex Filters for Pi-hole
This is a custom regex filter file for use with Pi-hole v4+ (FTLDNS).

There are also some optional regex filters separate to the main installer that need to be added manually (if desired):
* [Facebook](https://github.com/mmotti/pihole-regex/tree/master/social%20media)
* [Internationalized Domain Names](https://github.com/mmotti/pihole-regex/tree/master/internationalized%20domains)
* [Miscellaneous Items](https://github.com/mmotti/pihole-regex/tree/master/miscellaneous)
* [User Suggested](https://github.com/mmotti/pihole-regex/tree/master/miscellaneous/user%20suggested)

All commands will need to be entered via Terminal (PuTTY or your SSH client of choice) after logging in and [**Python 3.6+**](https://github.com/mmotti/pihole-regex/issues/16) is required.

### Add to Pi-Hole
```
curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/install.py | sudo python3
```

### Remove from Pi-Hole
```
curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/uninstall.py | sudo python3
```

### Keep regexps up-to-date with cron (optional)
The following instructions will create a cron job to run every monday at 02:30 (adjust the time to suit your needs):

1. Edit the root user's crontab (`sudo crontab -u root -e`)

2. Enter the following:
```
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
30 2 * * 1 /usr/bin/curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/install.py | /usr/bin/python3
```
3. Save changes

#### Removing the manually created cron job
If this script is the only thing you've added to the root user's crontab, you can run:

`sudo crontab -u root -r`

Otherwise, run:

`sudo crontab -u root -e` and remove the three lines listed above in the install instructions.
