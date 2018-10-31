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
	. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/WebminQuestions.sh"
	
fi


if [ "${Miscelangelous[SETUP_Webmin]}" -eq "1" ]; then
	# Install packages for Webmin
	apt install -y zip perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python

	# Install Webmin
	sed -i '$a deb http://download.webmin.com/download/repository sarge contrib' /etc/apt/sources.list
	if wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -
	then
		apt update -q4 & spinner_loading
		apt install webmin -y
	fi
fi
