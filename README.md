## Regex Filters for Pi-hole
This is a custom `regex.list` file for use with Pi-hole v4+ (FTLDNS).

All commands will need to be entered via Terminal (PuTTY or your SSH client of choice) after logging in.

## Warning ##
**The install process will remove all custom regexps that are not in the standard Pi-hole wildcard regexp format (e.g. `(^|\.)test\.com$`)**. If you have specified your own custom regexps it is recommended that you make a backup before continuing.

### [OPTIONAL] Back up your existing regex list
```
sudo cp /etc/pihole/regex.list /etc/pihole/regex.list.bak
```

### Installation Instructions
```
curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/install.sh | bash 
```

### Removal Instructions
```
sudo bash
grep "^(\^|.*\$$" /etc/pihole/regex.list | sudo tee "/etc/pihole/regex.list"
killall -SIGHUP pihole-FTL
exit
```

### Testing the regex filter
See if you can access https://ad.pi-hole.net/

Then check the query log in the Pi-hole admin console for your blocked domain. It should show as **Pi-holed (wildcard)**.

![alt test](https://image.ibb.co/j5kWTz/Blocked.png)
