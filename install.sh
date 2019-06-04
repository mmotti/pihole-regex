#!/usr/bin/env bash

# Set variables
db_gravity='/etc/pihole/gravity.db'
file_pihole_regex='/etc/pihole/regex.list'
file_csv_tmp="$(mktemp -p "/tmp" --suffix=".gravity")"
file_mmotti_regex='/etc/pihole/mmotti-regex.list'
installer_comment='github.com/mmotti/pihole-regex'

# Determine whether we are using Pi-hole DB
if [[ -e "${db_gravity}" ]] && [[ -s "${db_gravity}" ]]; then
	usingDB=true
fi

# Functions
function fetchResults {

	local selection="${1}" action="${2}" queryStr

	# Select * if not set
	[[ -z "${selection}" ]] && selection='*'

	# Determine course of action
	case "${action}" in
		migrated_regexps ) queryStr="Select ${selection} FROM regex WHERE comment='${installer_comment}'";;
		user_created     ) queryStr="Select ${selection} FROM regex WHERE comment IS NULL OR comment!='${installer_comment}'";;
		current_id       ) queryStr="Select ${selection} FROM regex ORDER BY id DESC LIMIT 1";;
		*                ) queryStr="Select ${selection} FROM regex";;
	esac

	# Execute SQL query
	sqlite3 ${db_gravity} "${queryStr}" 2>&1
	# Check exit status
	status="$?"
	[[ "${status}" -ne 0 ]]  && echo '[i] An error occured whilst fetching results' && exit 1

	return
}

function updateDB() {

	local inputData="${1}" action="${2}" queryStr

	# Determine course of action
	case "${action}" in
		remove_pre_migrated ) queryStr="DELETE FROM regex WHERE domain in (${inputData})";;
		remove_migrated     ) queryStr="DELETE FROM regex WHERE comment = '${installer_comment}'";;
		*                   ) return ;;
	esac

	# Execute SQL query
	sudo sqlite3 ${db_gravity} "${queryStr}"
	# Check exit status
	status="$?"
	[[ "${status}" -ne 0 ]]  && echo '[i] An error occured whilst updating database' && exit 1

	return
}

echo "[i] Fetching mmotti's regexps"
mmotti_remote_regex=$(sudo wget -qO - https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list | grep '^[^#]')
[[ -z "${mmotti_remote_regex}" ]] && { echo '[i] Failed to download mmotti regex list'; exit 1; }

echo '[i] Fetching existing regexps'

# Conditional (db / old) variables
if [[ "${usingDB}" == true ]]; then
	str_regex=$(fetchResults "domain")
else
	[[ ! -s "${file_pihole_regex}" ]] && { echo "[i] ${file_pihole_regex} is empty or does not exist"; exit 1; }
	str_regex=$(grep '^[^#]' < "${file_pihole_regex}")
fi

# If we're using the Pi-hole DB
if [[ "${usingDB}" == true ]]; then
	# If there are regexps in the DB
	if [[ -n "${str_regex}" ]] ; then
		echo '[i] Checking for previous migration'
		# Check whether there are migrated entries
		db_migrated_regexps=$(fetchResults "domain" "migrated_regexps")
		# If migration is detected
		if [[ -n "${db_migrated_regexps}" ]]; then
			echo '[i] Previous migration detected'
			# Check to see whether local DB is up-to-date
			# Suppress lines that appear in both files
			# If there are no differences between the local migrated regexps and remote regexps
			# there is nothing to process
			echo '[i] Checking whether updates are required'
			updatesRequired=$(comm -3 <(sort <<< "${db_migrated_regexps}") <(sort <<< "${mmotti_remote_regex}"))
			[[ -z "${updatesRequired}" ]] && echo '[i] Local regex filter is already up-to-date' && exit 0
			# Otherwise we need to remove the existing migrated regexps
			# and re-populate
			echo '[i] Running removal query'
			updateDB "" "remove_migrated"
		else
			echo '[i] No previous migration detected'
			# As we haven't yet migrated, we need to manually remove matches
			# If we have a local mmotti-regex.list, read from that as it was used on the last install (pre-db)
			# Otherwise, default to the latest remote copy
			if [[ -e "${file_mmotti_regex}" ]] && [[ -s "${file_mmotti_regex}" ]]; then
				mapfile -t result <<< "$(comm -12 <(sort <<< "${str_regex}") <(sort < "${file_mmotti_regex}"))"
				if [[ -n "${result[*]}" ]]; then
					echo '[i] Forming removal string'
					removalStr=$(printf "'%s'," "${result[@]}" | sed 's/,$//')
				fi
			else
				mapfile -t result <<< "$(comm -12 <(sort <<< "${str_regex}") <(sort <<< "${mmotti_remote_regex}"))"
				if [[ -n "${result[*]}" ]]; then
					echo '[i] Forming removal string'
					removalStr=$(printf "'%s'," "${result[@]}" | sed 's/,$//')
				fi
			fi

			# If we formed a removal string, then run it
			if [[ -n "${removalStr}" ]]; then
				echo '[i] Running removal query'
				updateDB "${removalStr}" "remove_pre_migrated"
			fi
		fi
	else
		echo '[i] No regexps currently exist in the database'
	fi

	# Status update
	echo '[i] Generating CSV file'

	# Grab the current timestamp
	timestamp="$(date --utc +'%s')"
	# Fetch the current highest ID in the regex DB
	# If there are no results
	i=$(fetchResults "id" "current_id")
	if [[ -z "${i}" ]]; then
		# Set iterator to 1
		i=1
	else
		# Increment the value by one
		((i++))
	fi
	# Iterate through the remote regexps
	# So long as the line is not empty, generate the CSV values
	while read -r regexp; do
		if [[ -n "${regexp}" ]]; then
			echo "${i},\"${regexp}\",1,${timestamp},${timestamp},\"${installer_comment}\"" >> "${file_csv_tmp}"
			((i++))
		fi
	done <<< "${mmotti_remote_regex}"
	# Construct correct input format for import
	echo '[i] Importing CSV to DB'
	printf ".mode csv\\n.import \"%s\" %s\\n" "${file_csv_tmp}" "regex" | sudo sqlite3 "${db_gravity}"
	# Check exit status
	status="$?"
	[[ "${status}" -ne 0 ]]  && echo '[i] An error occured whilst importing the CSV into the database' && exit 1
	# Output current regexps to user
	echo '[i] Regex import complete'
	# Refresh Pi-hole
	echo '[i] Refreshing Pi-hole'
	sudo killall -SIGHUP pihole-FTL
	# Remove the old mmotti-regex file
	sudo rm -f "${file_mmotti_regex}"
	# Output regexps currently in the DB
	printf '\n'
	fetchResults "domain"

	exit
else
	# Restore config prior to previous install
	# Keep entries only unique to pihole regex
	if [ -s "$file_pihole_regex" ] && [ -s "$file_mmotti_regex" ]; then
		echo "[i] Removing mmotti's regex.list from a previous install"
		comm -23 <(sort $file_pihole_regex) <(sort $file_mmotti_regex) | sudo tee $file_pihole_regex > /dev/null
		sudo rm -f $file_mmotti_regex
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
fi
