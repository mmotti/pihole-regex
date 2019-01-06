#!/usr/bin/env bash

# Get existing Pi-Hole style wildcards
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