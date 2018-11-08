#!/bin/bash

###	Variables
MAIN_SETUP=1
DEBUG=0

BGreen='\e[1;32m'       # Green
BRed='\e[1;31m'         # Red
Color_Off='\e[0m'       # Text Reset

Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
Github_Branch="master"
Local_Repository="/home/georg/github/ggeorgg/setup-server"
DIR_STATIC=static

if [ ! -f "${Local_Repository}/source_file.sh" ]; then
	printf "${BGreen}We will now download ${Github_Repository}/${Github_Branch}/source_file.sh${Color_Off}\n"
	curl -sLf "${Github_Repository}/${Github_Branch}/source_file.sh" --create-dirs -o "${Local_Repository}/source_file.sh"

	exit_status=$?
	if [[ $exit_status != 0 ]]; then
		printf "${BRed}Sorry, but we couldn't download ${Github_Repository}/${Github_Branch}/source_file.sh${Color_Off}\n"
		exit $exit_status
	fi
	unset $exit_status
fi

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


if [[ ! -f "${Local_Repository}/main_running" ]]; then

	workflow=()
	workflow+=("${DIR_STATIC}/pre_setup.sh")
	workflow+=("${DIR_STATIC}/add_user.sh")
	workflow+=("${DIR_STATIC}/change_dns.sh")
	workflow+=("${DIR_STATIC}/setup_disk.sh")
	workflow+=("${DIR_STATIC}/setup_dbms.sh")
	workflow+=("${DIR_STATIC}/setup_webserver.sh")
	workflow+=("${DIR_STATIC}/setup_php.sh")
	workflow+=("${DIR_STATIC}/setup_nextcloud.sh")
	workflow+=("${DIR_STATIC}/setup_op_cache.sh")
	workflow+=("${DIR_STATIC}/generate_virtual_hosts.sh.sh")
	workflow+=("${DIR_STATIC}/setup_nextcloud_apps.sh")
	workflow+=("${DIR_STATIC}/change_unix_user_profile.sh")
	workflow+=("${DIR_STATIC}/setup_redis.sh")
	workflow+=("${DIR_STATIC}/finish_setup.sh")
	# Contintue after reboot (More or less the startup script):
	workflow+=("${DIR_STATIC}/first_startup.sh")
	# workflow+=("${DIR_STATIC}/setup_ssl.sh")		# Has to be activated in the future...
	workflow+=("${DIR_STATIC}/setup_extra_software.sh")
	# workflow+=("${DIR_STATIC}/setup_server_startup_welcome_screen.sh")	# TBD
	# workflow+=("${DIR_STATIC}/XXXXX.sh")
	# workflow+=("${DIR_STATIC}/change_passwords.sh")	# Has to be activated in the future...
	workflow+=("${DIR_STATIC}/cleanup.sh")
	
	. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/read_config_file_to_array.sh" "${DIR_STATIC}/descriptions.cfg" "Description"

	. "${Local_Repository}/source_file.sh" "${DIR_Questions}/main_setup_questions.sh"

	## Edit configuration according to the users wishes

	if [ "${CONFIG[setup_server_method]}" = 'no_interaction' ]; then

		# Check if config file is misconfigured (needs to be done only in the NoInteraction Setup
		# because in the other cases the script will handle the correctness of the config file
		# . "${Local_Repository}/source_file.sh" "${DIR_STATIC}/CheckConfig.sh"

		# Set Timezone non interactive ( Only if SETUP = NoInteraction), else: Ask directly for it.
		sudo timedatectl set-timezone "${Timezone[continent]}/${Timezone[city]}"
		# timedatectl status
		
	elif [ "${CONFIG[setup_server_method]}" = 'simple_setup' ]; then

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/questions_add_user.sh"

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/DataDiskQuestions.sh"
		
	elif [ "${CONFIG[setup_server_method]}" = 'advanced_setup' ]; then

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/AddUserQuestions.sh"

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/DataDiskQuestions.sh"

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/questions_timezone.sh"

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/KeyboardLayoutQuestions.sh"

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/BestMirrorQuestions.sh"

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/questions_webserver.sh"

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/SSLQuestions.sh"

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/questions_setup_dbms.sh"

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/NextcloudAppsQuestions.sh"
		
		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/questions_setup_office.sh"

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/questions_communication_system.sh"

		. "${Local_Repository}/source_file.sh" "${DIR_Questions}/ExtraSoftwareQuestions.sh"
				
	fi

	## Display Warnings and messages?
	# Open Port 443 usw.

	
	## Execute the needed scripts in the right order.

	echo "Here is a List of scripts that will be executed now."
	printf " - %s\n" "${workflow[@]}"

	any_key "Press any key to execute the scripts. Press CTRL+C to abort"
	
	# Create a file as flag (e.g. to know after a reboot, that we can skip the questions)
	touch "${Local_Repository}/main_running"
	
	# Save config to file because it has changed
	. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/update_config_file.sh" "UserConfigElementsList" "userconfig.cfg"
	

	# Write the workflow array to a file
	printf "%s\n" "${workflow[@]}" > workflow.txt

fi

# Process the scripts / Continue processing the scripts (if e.g. after a reboot or after an 'exec main.sh' statement)
. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/process_queue.sh" "workflow.txt"

any_key "Installation finished, press any key to reboot system..."

reboot
