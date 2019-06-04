#!/usr/bin/env bash

# Variables
db_gravity='/etc/pihole/gravity.db'
installer_comment='github.com/mmotti/pihole-regex'

# Set regex outputs
file_pihole_regex="/etc/pihole/regex.list"
file_mmotti_regex="/etc/pihole/mmotti-regex.list"

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

# If we are uninstalling from the Pi-hole DB, we need to accommodate for
# pi-hole migrated and installer migrated

# If we are using the DB
if [[ "${usingDB}" == true ]]; then
	echo '[i] Fetching regexps in gravity DB'
	str_regex=$(fetchResults "domain")

	# If there are regexps in the DB
	if [[ -n "${str_regex}" ]] ; then
		echo '[i] Checking for previous migration'
		# Check whether there are migrated entries
		db_migrated_regexps=$(fetchResults "domain" "migrated_regexps")
		# If migration is detected
		if [[ -n "${db_migrated_regexps}" ]]; then
			echo '[i] Previous migration detected'
			# If we detect a previous migration, we can simply remove
			# by the comment field
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
				# Fetch remote regexps
				echo "[i] Fetching mmotti's regexps"
				mmotti_remote_regex=$(sudo wget -qO - https://raw.githubusercontent.com/mmotti/pihole-regex/master/regex.list | grep '^[^#]')
				[[ -z "${mmotti_remote_regex}" ]] && { echo '[i] Failed to download mmotti regex list'; exit 1; }

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
				exit 0
			fi
		fi
	else
		echo '[i] No regexps currently exist in the database'
		exit 0
	fi

	# Refresh Pi-hole
	echo '[i] Refreshing Pi-hole'
	sudo killall -SIGHUP pihole-FTL

else
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
fi