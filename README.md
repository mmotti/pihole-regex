## Regex Filters for Pi-hole
This is a custom regex filter file for use with Pi-hole v4+ (FTLDNS).

There are also optional regex filters for [Facebook](https://github.com/mmotti/pihole-regex/tree/master/social%20media) and [Internationalized Domain Names](https://github.com/mmotti/pihole-regex/tree/master/internationalized%20domains) which will be separate to the installer and each entry will need to be added manually.

All commands will need to be entered via Terminal (PuTTY or your SSH client of choice) after logging in.

### Why use the installer?
The installer will determine whether you are using the Pi-hole database (v5.0+) or the older style regex.list, then evaluate your current regular expressions and act accordingly. It has been created to make life easier.

#### Installer Requirements
This script requires [**Python 3.6+**](https://github.com/mmotti/pihole-regex/issues/16) in order to run correctly. It has been written and tested for Raspbian Buster and Ubuntu Server.

If you experience **syntax errors** due to the use of f-strings, this is likely because your installed version of Python is **below 3.6**.

#### Why is root (sudo) required by the installer?
At the time of the scripts creation, it is necessary to run as root in order to modify files in `/etc/pihole` (`regex.list` and `gravity.db`)

#### Can I use these regexps without using the installer?
Yes, you can. You can enter them one by one in the Pi-hole web interface.

### [OPTIONAL] Back up your existing regex list

If you are using the new **Pi-hole DB**
```
sudo cp /etc/pihole/gravity.db /etc/pihole/gravity.db.bak
```

If you are using the older style **regex.list**:
```
sudo cp /etc/pihole/regex.list /etc/pihole/regex.list.bak
```

### Installation
```
curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/install.py | sudo python3
```

#### OPTIONAL: Keeping regexps up-to-date
The following instructions will create a cron job to run each morning at 02:45 (adjust the time to suit your needs):

1. Edit the root user's crontab (`sudo crontab -u root -e`)

2. Enter the following:
```
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
45 2 * * * /usr/bin/curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/install.py | /usr/bin/python3
```
3. Save changes

### Removal
```
curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/uninstall.py | sudo python3
```

#### Removing the cron job (if you created one)
If this script is the only thing you've added to the root user's crontab, you can run:

`sudo crontab -u root -r`

Otherwise, run:

`sudo crontab -u root -e` and remove the three lines listed above in the install instructions.
