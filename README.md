## Pi-hole regex filters

This regex list has been created with the wildcards identified from my work on a [Knox Firewall host file](https://github.com/mmotti/mmotti-host-file).

As Pi-hole allows much greater flexibility with regex filtering, this list is expected to grow and deviate from the standard `*.something` or `something.*`

In order to utilise this list, it is currently necessary to be on the **development** branch of Pi-Hole. This will change in future, but, as the regex feature is still under development, it is not currently part of the master or FTLDNS branches. 

### Installation
1. Copy `regex.list` to `/etc/pihole/` (`/etc/pihole/regex.list`)
2. Restart the Pi-hole FTL service (`sudo service pihole-FTL restart`) 

OR

1. Manually create the `regex.list` file (`sudo nano /etc/pihole/regex.list`)
2. Paste the contents of `regex.list`, ensuring that each regex entry is on a new line
3. Press `CTRL` and `X`
4. Press `Y`
5. Press `Enter`
6. Restart the Pi-hole FTL service (`sudo service pihole-FTL restart`) 