## Pi-hole regex filters
This is a custom (unofficial) **regex.list** file for use with Pi-hole **version 4 or above**.

https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list

### Installation
To successfully enable regex blocking we need to create a regex.list file, save it in the appropriate directory and tell Pi-hole FTL to reload the config.

The following instructions have been tested on a Raspberry Pi 3 Model B running Raspian Stretch, in the context of the default `pi` user account.

First of all, open up Putty (or your choice of SSH client) and login to your device. In my case, the IP address for my Raspberry Pi is `192.168.1.2`.

Login with your user account (default: `pi`).

Run the following commands:
1. `sudo curl https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list -o /etc/pihole/regex.list`
2. `sudo killall -SIGHUP pihole-FTL`

### Testing the regex filter
See if you can access http://ads.sdsdsfdsgsf.com

Then check the query log in the Pi-hole admin console for your blocked domain. It should show as **Pi-holed (wildcard)**.

![alt test](https://image.ibb.co/doq6Tz/Blocked.png)
