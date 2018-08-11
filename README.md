## Regex Filters for Pi-hole
This is a custom `regex.list` file for use with Pi-hole v4+ (FTLDNS).

All commands will need to be entered via Terminal (PuTTY or your SSH client of choice) after logging in.

### [OPTIONAL] Back up your existing regex list
```
sudo cp /etc/pihole/regex.list /etc/pihole/regex.list.bak
```

### [OPTIONAL] Remove old Wildcard Suffixes
If you've installed this list prior to 11 August 2018, you will want to remove the old Wildcard Suffixes
```
sed -E -i '/(amazon-adsystem|kaffnet|startapp\(exchange)/d' /etc/pihole/regex.list
```

### Installation Instructions
```
list="$(grep "^(\^|.*\$$" /etc/pihole/regex.list)"
list+="
$(wget -qO - https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list)"
sort -u <<< "$list" | grep -v "^#" | sudo tee /etc/pihole/regex.list
sudo killall -SIGHUP pihole-FTL
```

### Removal Instructions
```
grep "^(\^|.*\$$" /etc/pihole/regex.list | sudo tee /etc/pihole/regex.list"
sudo killall -SIGHUP pihole-FTL
```

### Testing the regex filter
See if you can access https://ad.pi-hole.net/

Then check the query log in the Pi-hole admin console for your blocked domain. It should show as **Pi-holed (wildcard)**.

![alt test](https://image.ibb.co/j5kWTz/Blocked.png)
