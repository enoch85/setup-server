#!/bin/bash
if [[ -z ${MAIN_SETUP+x} ]]; then
	###	Variables
	DEBUG=0
	
	BGreen='\e[1;32m'       # Green
	BRed='\e[1;31m'         # Red
	Color_Off='\e[0m'       # Text Reset
	
	Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
	Github_Branch="master"
	Local_Repository="/home/georg/github/ggeorgg/setup-server"
	DIR_STATIC=static
	
	### Code
	
	printf "${BGreen}We will now download ${Github_Repository}/${Github_Branch}/source_file.sh${Color_Off}\n"
	curl -sLf "${Github_Repository}/${Github_Branch}/source_file.sh" --create-dirs -o "${Local_Repository}/source_file.sh"

	exit_status=$?
	if [[ $exit_status != 0 ]]; then
		printf "${BRed}Sorry, but we couldn't download ${Github_Repository}/${Github_Branch}/source_file.sh${Color_Off}\n"
		exit $exit_status
	fi
	unset $exit_status
	
	# Global functions
	. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/global_functions.sh"
	# Global parameter
	. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/global_parameter.sh"
	# Bash colors
	. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/bash_colors.sh"
	
	set_debug_mode
	exit_if_not_root
	
	
	# Read config
	. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/read_config_file_to_array.sh" "userconfig.cfg" "UserConfigElementsList"
	
	## Questions
	. "${Local_Repository}/source_file.sh" "${DIR_Questions}/questions_setup_dbms.sh"
	
fi

if [ "${DBMS[PostgreSQL]}" -eq "1" ]; then
	# Install PostgreSQL
	# sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main"
	# wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
	apt update -q4 & spinner_loading
	apt install postgresql-10 -y

	# Create DB
	# cd /tmp
sudo -u postgres psql <<END
CREATE USER ${USER_SETTINGS[nc_admin_username]} WITH PASSWORD '$PGDB_PASS';
CREATE DATABASE nextcloud_db WITH OWNER ${USER_SETTINGS[nc_admin_username]} TEMPLATE template0 ENCODING 'UTF8';
END
	service postgresql restart
	
elif [ "${DBMS[MariaDB]}" -eq "1" ]; then
	echo "MariaDB not implemented yet"
	exit
fi
