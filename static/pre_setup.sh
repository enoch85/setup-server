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
	# No questions
	
fi

# Check if dpkg or apt is running
is_process_running apt
is_process_running dpkg

## Install needed packages

install_if_not lshw

install_if_not net-tools

# Install needed network
install_if_not netplan.io
install_if_not network-manager

# Test RAM size (2GB min) + CPUs (min 1) (Only if Office or Fulltextsearch? Or change the limits dynamicly?
ram_check 2 Nextcloud
cpu_check 1 Nextcloud

# Check distribution and version
check_distro_version
check_universe

# Check if key is available
if ! curl -sL -w "%{http_code}\n" "$NCREPO" -o /dev/null; then	# How to avoid output of http_code to console?
# if ! wget -q -T 10 -t 2 "$NCREPO" > /dev/null; then
	echo "Nextcloud repo ($NCREPO) is not available, exiting..."
	exit 1
fi

# Check if it's a clean server
# is_this_installed postgresql
# is_this_installed apache2
# is_this_installed php
# is_this_installed php-fpm
# is_this_installed php7.2-fpm
# is_this_installed php7.1-fpm
# is_this_installed php7.0-fpm
# is_this_installed mysql-common
# is_this_installed mariadb-server

# Set locales - notwendig?
# install_if_not language-pack-en-base
# sudo locale-gen "sv_SE.UTF-8" && sudo dpkg-reconfigure --frontend=noninteractive locales	