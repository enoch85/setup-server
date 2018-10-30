#!/bin/bash
if [ -z "$MAIN_SETUP" ]; then
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
	. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/WebserverQuestions.sh"
	
fi

if [ "${Webserver[Apache2]}" -eq "1" ]; then
	# Install Apache
	check_command apt install apache2 -y 
	a2enmod rewrite \
			headers \
			proxy \
			proxy_fcgi \
			setenvif \
			env \
			mime \
			dir \
			authz_core \
			alias \
			ssl

	# We don't use Apache PHP (just to be sure)
	a2dismod mpm_prefork

elif [ "${Webserver[NGINX]}" -eq "1" ]; then
	echo "NGINX not implemented yet!"
	exit
fi
