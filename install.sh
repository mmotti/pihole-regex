#!/usr/bin/env bash
# shellcheck disable=SC1117

# Get existing Pi-Hole style wildcards
# (^|\.)test\.com$
echo "--> Identifying Pi-hole wildcards"
pihole_wildcards="$(grep "^(\^|.*\$$" /etc/pihole/regex.list)"

# Fetch mmotti regex.list
echo "--> Fetching mmotti's regex.list"
mmotti_regex=$(wget -qO - https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list)

# Exit if unable to download list
if [ -z "$mmotti_regex" ]; then
	echo "Error: Unable to fetch mmotti regex.list"
	exit
else
	echo "--> $(wc -l <<< "$mmotti_regex") regexps found in mmotti's regex.list"
fi

# Form output (preserving Pi-hole wildcards)
if [ -z "$pihole_wildcards" ]; then
	echo "--> No Pi-hole specific wildcards detected"
	final_regex=$(printf "%s\n" "$mmotti_regex")
else
	echo "--> $(wc -l <<< "$pihole_wildcards") Pi-hole specific wildcards detected"
	final_regex=$(printf "%s\n" "$mmotti_regex" "$pihole_wildcards")
fi

# Output to regex.list
echo "--> Saving to /etc/pihole/regex.list"
LC_COLLATE=C sort -u <<< "$final_regex" | sudo tee /etc/pihole/regex.list > /dev/null

# Refresh Pi-hole
echo "--> Refreshing Pi-hole"
sudo killall -SIGHUP pihole-FTL

echo "--> Done"

# Output to user
echo $'\n'
cat /etc/pihole/regex.list
