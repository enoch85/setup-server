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
	. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/WebserverQuestions.sh"
	
fi

if [ "${Webserver[Apache2]}" -eq "1" ]
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
	
	# Enable HTTP/2 server wide (Wurde vorher nach der Installation von php gemacht. Ist es Ok das auch schon vorher zu machen?
	echo "Enabling HTTP/2 server wide..."
	# https://httpd.apache.org/docs/2.4/mod/mod_http2.html
cat << HTTP2_ENABLE > "$HTTP2_CONF"
<IfModule http2_module>
    Protocols h2 h2c http/1.1
    H2Direct on
</IfModule>
HTTP2_ENABLE
	echo "$HTTP2_CONF was successfully created"
	a2enmod http2
	restart_webserver
	
elif [ "${Webserver[NGINX]}" -eq "1" ]
	echo "NGINX not implemented yet!"
	exit
fi
