## Regex Filters for Pi-hole
This is a custom regex filter file for use with Pi-hole v4+ (FTLDNS).

All commands will need to be entered via Terminal (PuTTY or your SSH client of choice) after logging in.

### Why use the installer?
The installer will determine whether you are using the Pi-hole database or the older style regex.list, then evaluate your current regular expressions and act accordingly. It has been created to make life easier.

### Why is root (sudo) required by the installer?
At the time of the scripts creation, it is necessary to run as root in order to modify files in `/etc/pihole` (`regex.list` and `gravity.db`)

### Can I use these regexps without using the installer?
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

### Removal
```
curl -sSl https://raw.githubusercontent.com/mmotti/pihole-regex/master/uninstall.py | sudo python3
```
