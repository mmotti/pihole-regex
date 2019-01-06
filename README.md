## Regex Filters for Pi-hole
This is a custom `regex.list` file for use with Pi-hole v4+ (FTLDNS).

All commands will need to be entered (copy/paste) via Terminal (PuTTY or your SSH client of choice) after logging in.

## Warning ##
**The install commands will remove all custom regexps that are not in the standard Pi-hole wildcard regexp format (e.g. `(^|\.)test\.com$`)**. If you have specified your own custom regexps it is recommended that you make a backup before continuing.

### [OPTIONAL] Back up your existing regex list
```
sudo cp /etc/pihole/regex.list /etc/pihole/regex.list.bak
```

### Installation Instructions
```
sudo bash

# Get existing Pi-hole style wildcards
# (^|\.)test\.com$
pihole_wildcards="$(grep "^(\^|.*\$$" /etc/pihole/regex.list)"

# Fetch mmotti regex.list
mmotti_regex=$(wget -qO - https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list)

# Exit if unable to download list
if [ -z "$mmotti_regex" ]; then
	echo "Error: Unable to fetch mmotti regex.list"
	exit
fi

# Form output (preserving Pi-hole wildcards)
if [ -z "$pihole_wildcards" ]; then
	final_regex=$(printf "%s\n" "$mmotti_regex")
else
	final_regex=$(printf "%s\n" "$mmotti_regex" "$pihole_wildcards")
fi

# Output to regex.list
LC_COLLATE=C sort -u <<< "$final_regex" | sudo tee /etc/pihole/regex.list

# Refresh Pi-hole
killall -SIGHUP pihole-FTL

exit
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
