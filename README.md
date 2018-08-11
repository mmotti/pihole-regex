## Pi-hole regex filters
This is a custom (unofficial) regex.list file for use with Pi-hole version 4 or above.

Please be aware that the removal instructions will delete any custom wildcards that you have specified to be blocked; so don't forget to make a note of these before continuing.

### Installation Instructions
1. Open up Putty (or your choice of SSH client) and login to your device
2. Run the following commands (Credit: [@WaLLy3K](https://github.com/WaLLy3K)):
```
list="$(grep "^(\^|.*\$$" /etc/pihole/regex.list)"
list+="
$(wget -qO - https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list)"
sort -u <<< "$list" | grep -v "#" | sudo tee /etc/pihole/regex.list
```

### Removal Instructions
1. Open up Putty (or your choice of SSH client) and login to your device
2. Run the following commands:
```
sudo bash -c "> /etc/pihole/regex.list"
sudo killall -SIGHUP pihole-FTL
```

### Testing the regex filter
See if you can access https://ad.pi-hole.net/

Then check the query log in the Pi-hole admin console for your blocked domain. It should show as **Pi-holed (wildcard)**.

![alt test](https://image.ibb.co/j5kWTz/Blocked.png)
