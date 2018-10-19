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
	. "${Local_Repository}/source_file.sh" "${DIR_Questions}/questions_add_user.sh"
	
fi

if [[ "${USER_SETTINGS[add_unix_sudo_user]}" -eq 1 ]]; then
	msg_box "We will create the new user with sudo permissions now.\nYou will be prompted to choose a password"
	sudo adduser --disabled-password --gecos "" "${USER_SETTINGS[unix_sudo_username]}"
	sudo usermod -aG sudo "${USER_SETTINGS[unix_sudo_username]}"
	sudo usermod -s /bin/bash "${USER_SETTINGS[unix_sudo_username]}"
	while true
	do
		sudo passwd "${USER_SETTINGS[unix_sudo_username]}" && break
	done
	if [[ ! -z ${MAIN_SETUP+x} ]]; then
		# Save config to file because it has changed previously
		. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/update_config_file.sh" "UserConfigElementsList" "userconfig.cfg"
		
		printf "${BGreen}We will now execute the main script again, but we will skip the questions.${Color_Off}\n"
		# Execute script with the new user (use exec to not continue the script after this line)
		exec sudo -u ${USER_SETTINGS[unix_sudo_username]} sudo bash ${Local_Repository}/main.sh
	fi
fi
