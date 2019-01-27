#!/usr/bin/env bash
# shellcheck disable=SC1117

# Set regex outputs
file_pihole_regex="/etc/pihole/regex.list"
file_mmotti_regex="/etc/pihole/mmotti-regex.list"

# Restore config prior to previous install
# Keep entries only unique to pihole regex
if [ -s "$file_pihole_regex" ] && [ -s "$file_mmotti_regex" ]; then
	echo "[i] Removing mmotti's regex.list from a previous install"
	comm -23 <(sort $file_pihole_regex) <(sort $file_mmotti_regex) | sudo tee $file_pihole_regex > /dev/null
fi

# Fetch mmotti regex.list
echo "[i] Fetching mmotti's regex.list"
sudo wget -qO "$file_mmotti_regex" https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list

# Exit if unable to download list
if [ ! -s "$file_mmotti_regex" ]; then
        echo "Error: Unable to fetch mmotti regex.list"
        exit
else
        mmotti_regex="$(cat $file_mmotti_regex)"
        echo "[i] $(wc -l <<< "$mmotti_regex") regexps found in mmotti's regex.list"
fi

# Check existing configuration
if [ -s "$file_pihole_regex" ]; then
	# Extract non mmotti-regex entries
	existing_regex_list="$(cat $file_pihole_regex)"

	# Form output (preserving existing config)
        echo "[i] $(wc -l <<< "$existing_regex_list") regexps exist outside of mmotti's regex.list"
        final_regex=$(printf "%s\n" "$mmotti_regex" "$existing_regex_list")

else
	echo "[i] No regex.list differences to mmotti's regex.list"
	final_regex=$(printf "%s\n" "$mmotti_regex")

fi

# Output to regex.list
echo "[i] Saving to $file_pihole_regex"
LC_COLLATE=C sort -u <<< "$final_regex" | sudo tee $file_pihole_regex > /dev/null

# Refresh Pi-hole
echo "[i] Refreshing Pi-hole"
sudo killall -SIGHUP pihole-FTL

echo "[i] Done"

# Output to user
echo $'\n'
cat $file_pihole_regex
