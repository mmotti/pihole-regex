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
	sudo rm -f $file_mmotti_regex
else
	echo "[i] The circumstances are not appropriate for automated removal"
	exit
fi

# Refresh Pi-hole
echo "[i] Refreshing Pi-hole"
sudo killall -SIGHUP pihole-FTL

# Output to user
echo $'\n'
cat $file_pihole_regex
