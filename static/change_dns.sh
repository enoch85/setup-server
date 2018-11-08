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

# https://www.quad9.net/faq/
# Change DNS system wide
sed -i "s|#DNS=.*|DNS=9.9.9.9 2620:fe::fe|g" /etc/systemd/resolved.conf
sed -i "s|#FallbackDNS=.*|FallbackDNS=149.112.112.112 2620:fe::9|g" /etc/systemd/resolved.conf

check_command systemctl restart network-manager.service
network_ok
