## Pi-hole regex filters
This is a custom (unofficial) **regex.list** file for use with Pi-hole **version 4 or above**.

**Warning**: Running the install / reset commands will remove any custom wildcards that you have specified to be blocked. Please consider this and make a note of any existing wildcards before continuing as you will have to re-enter these manually.

### Installation Instructions
1. Open up Putty (or your choice of SSH client) and login to your device
2. Run the following commands:
```
sudo curl https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list -o /etc/pihole/regex.list
sudo killall -SIGHUP pihole-FTL
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
