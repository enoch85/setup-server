#!/bin/bash
if [ -z "$MAIN_SETUP" ]
then
	Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
	Github_Branch="master"
	UseLocalFiles=1	# This variable is for developement purposes, so that we don't have to push changes in a file to github befor testing it.
	Local_Repository="/home/georg/github/ggeorgg/setup-server"
	if [ ! -f "${Local_Repository}/source_file.sh" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	wget -O "${Local_Repository}/source_file.sh" "${Github_Repository}/${Github_Branch}/source_file.sh"
	fi
	# Include functions (download the config file and read it to arrays)
	. "${Local_Repository}/source_file.sh" "lib.sh"

	MAIN_SETUP=0
		
	## Questions
	# . "${Local_Repository}/source_file.sh" "${DIR_Questions}/ExtraSoftwareQuestions.sh"
	
fi

if [ "${Miscelangelous[SETUP_Webmin]}" -eq "1" ]; then
	. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/SetupWebmin.sh"
fi

if [ "${Miscelangelous[SETUP_Netdata]}" -eq "1" ]; then
	echo "SETUP_Netdata TBD"
fi

if [ "${Miscelangelous[SETUP_Adminer]}" -eq "1" ]; then
	echo "SETUP_Adminer TBD"
fi

if [ "${Miscelangelous[SETUP_Fail2ban]}" -eq "1" ]; then
	. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/SetupFail2Ban.sh"
fi

if [ "${SecureSSH[SETUP_SECURE_SSH]}" -eq "1" ]; then
	echo "SETUP_SECURE_SSH TBD"
fi

if [ "${Miscelangelous[SETUP_Security]}" -eq "1" ]; then
	echo "SETUP_STATIC_Security TBD"
	# run_static_script security
fi

if [ "${Miscelangelous[SETUP_ModSecurity]}" -eq "1" ]; then
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
# occ_command config:system:set trusted_domains 3 --value="$SUBDOMAIN"
# occ_command config:system:set trusted_domains 3 --value="$ADDRESS"	# Oder doch so?
. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/trusted.sh"	# Oder doch so?


# Prefer IPv6
sed -i "s|precedence ::ffff:0:0/96  100|#precedence ::ffff:0:0/96  100|g" /etc/gai.conf
