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

# Change PostgreSQL Password
# cd /tmp


########################
# Ask the user for a new password instead of using a random password?
########################

NCUSER="${SudoUser[Username]}"

sudo -u www-data php "$NCPATH"/occ config:system:set dbpassword --value="$NEWPGPASS"

if [ "$(sudo -u postgres psql -c "ALTER USER $NCUSER WITH PASSWORD '$NEWPGPASS'";)" == "ALTER ROLE" ]; then
    echo -e "${Green}Your new PosgreSQL Nextcloud password is: $NEWPGPASS${Color_Off}"
else
    echo "Changing PostgreSQL Nextcloud password failed."
    sed -i "s|  'dbpassword' =>.*|  'dbpassword' => '$NCCONFIGDBPASS',|g" /var/www/nextcloud/config/config.php
    echo "Nothing is changed. Your old password is: $NCCONFIGDBPASS"
    exit 1
fi
