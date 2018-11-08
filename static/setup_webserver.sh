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
	. "${Local_Repository}/source_file.sh" "${DIR_Questions}/questions_webserver.sh"
	
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
	
	# Fixes https://github.com/nextcloud/vm/issues/58
	a2dismod status	# Kann das auch schon an einer anderen stelle gemacht werden, sodass der Webserver nicht schon wieder neu gestartet werden muss?
	# restart_webserver	

elif [ "${Webserver[NGINX]}" -eq "1" ]; then
	echo "NGINX not implemented yet!"
	exit
fi
