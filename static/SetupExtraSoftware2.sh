# Fixes https://github.com/nextcloud/vm/issues/58
a2dismod status	# Kann das auch schon an einer anderen stelle gemacht werden, sodass der Webserver nicht schon wieder neu gestartet werden muss?
restart_webserver

# Increase max filesize (expects that changes are made in $PHP_INI)
# Here is a guide: https://www.techandme.se/increase-max-file-size/
configure_max_upload


#!/bin/bash
if [ -z "$MAIN_SETUP" ]
then
	Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
	Github_Branch="master"
	UseLocalFiles=1	# This variable is for developement purposes, so that we don't have to push changes in a file to github befor testing it.
	Local_Repository="/home/georg/github/ggeorgg/setup-server"
	if [ ! -f "${Local_Repository}/SourceFile.sh" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	wget -O "${Local_Repository}/SourceFile.sh" "${Github_Repository}/${Github_Branch}/SourceFile.sh"
	fi
	# Include functions (download the config file and read it to arrays)
	. "${Local_Repository}/SourceFile.sh" "lib.sh"

	MAIN_SETUP=0
		
	## Questions
	# . "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/AddUserQuestions.sh"
	
fi

if [ "${Miscelangelous[SETUP_STATIC_Security]}" -eq "1" ]; then
	echo "SETUP_STATIC_Security TBD"
	# run_static_script security
fi

if [ "${Miscelangelous[SETUP_STATIC_ModSecurity]}" -eq "1" ]; then
	echo "SETUP_STATIC_ModSecurity TBD"
	# run_static_script modsecurity
fi

if [ "${Miscelangelous[SETUP_STATIC_IP]}" -eq "1" ]; then
	echo "SETUP_STATIC_IP TBD"
	# run_static_script set_static_ip
fi



# Calculate max_children after all apps are installed
calculate_max_children
check_command sed -i "s|pm.max_children.*|pm.max_children = $PHP_FPM_MAX_CHILDREN|g" $PHP_POOL_DIR/nextcloud.conf
restart_webserver

# # Set trusted domain in config.php
# if [ -f "$SCRIPTS"/trusted.sh ] 
# then
    # bash "$SCRIPTS"/trusted.sh # Can be done with an occ command???
    # rm -f "$SCRIPTS"/trusted.sh
# fi

# Prefer IPv6
sed -i "s|precedence ::ffff:0:0/96  100|#precedence ::ffff:0:0/96  100|g" /etc/gai.conf
