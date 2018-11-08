#!/bin/bash
if [ -z "$MAIN_SETUP" ]; then
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
	# . "${Local_Repository}/source_file.sh" "${DIR_Questions}/WebserverQuestions.sh"
	
fi

if [ ! -f "${Local_Repository}/${DIR_STATIC}/update-ncconfig.php" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	wget -O "${Local_Repository}/${DIR_STATIC}/update-ncconfig.php" "${Github_Repository}/${Github_Branch}/${DIR_STATIC}/update-ncconfig.php"
fi

if [ -f "${Local_Repository}/${DIR_STATIC}/update-ncconfig.php" ]
then
    # Change config.php
    php "${Local_Repository}/${DIR_STATIC}/update-ncconfig.php" $NCPATH/config/config.php 'trusted_domains[]' localhost "${ADDRESS[@]}" "$(hostname)" "$(hostname --fqdn)" >/dev/null 2>&1
    php "${Local_Repository}/${DIR_STATIC}/update-ncconfig.php" $NCPATH/config/config.php overwrite.cli.url https://"$(hostname --fqdn)"/ >/dev/null 2>&1

    # Change .htaccess accordingly
    sed -i "s|RewriteBase /nextcloud|RewriteBase /|g" $NCPATH/.htaccess

    # Cleanup
    # rm -f $SCRIPTS/update-ncconfig.php
fi
