#!/bin/bash
# MAIN_SETUP needs to be set here to prevent the functions.sh import to set subshell_active=1
MAIN_SETUP=1

# The next lines needs to be included and executed in each subfile if variable "MAIN_SETUP" does not exist or is 0
Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
Github_Branch="master"
UseLocalFiles=1	# This variable is for developement purposes, so that we don't have to push changes in a file to github befor testing it.
Local_Repository="/home/georg/github/ggeorgg/setup-server"
if [ ! -f "${Local_Repository}/SourceFile.sh" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	wget -O "${Local_Repository}/SourceFile.sh" "${Github_Repository}/${Github_Branch}/SourceFile.sh"
fi
# Include functions (download the config file and read it to arrays)
. "${Local_Repository}/SourceFile.sh" "lib.sh"

###############################################################################################
###############################################################################################
###############################################################################################

if [ "${DoNotEdit[MainAlreadyRunning]}" -eq "0" ]; then

	workflow=()
	workflow+=("${DIR_STATIC}/adduser.sh")
	workflow+=("${DIR_STATIC}/changeDNS.sh")
	workflow+=("${DIR_STATIC}/format-device.sh")
	workflow+=("${DIR_STATIC}/SetupDatabase.sh")
	workflow+=("${DIR_STATIC}/SetupWebserver.sh")
	workflow+=("${DIR_STATIC}/SetupPHP.sh")
	workflow+=("${DIR_STATIC}/SetupNextcloud.sh")
	workflow+=("${DIR_STATIC}/SetupOPCache.sh")
	workflow+=("${DIR_STATIC}/GenerateVirtualHosts.sh")
	workflow+=("${DIR_STATIC}/NextcloudApps.sh")
	# workflow+=("${DIR_STATIC}/SetupNextcloud.sh")
	# workflow+=("${DIR_STATIC}/SetupNextcloud.sh")
	# workflow[3]="Figlet"
	# workflow[4]="SetupSSL"
	# workflow[5]="SetupRedis"
	# workflow[6]="Fail2ban"
	# workflow[7]="Adminer"
	# workflow[8]="Netdata"
	# workflow[9]="OnlyOffice"
	# workflow[10]="Collabora"
	# workflow[11]="Security"
	# workflow[12]="ModSecurity"
	# workflow[13]="StaticIP"
	# workflow[14]="SecureSSH"
	# ...

	. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/SetupQuestions.sh"

	## Edit ${CONFIG} file according to the users wishes

	if [ "$SETUP" = "NoInteraction" ]; then
		SetupServerMethod[NoInteraction]=1
		SetupServerMethod[SimpleSetup]=0
		SetupServerMethod[AdvancedSetup]=0

		# Check if config file is misconfigured (needs to be done only in the NoInteraction Setup
		# because in the other cases the script will handle the correctness of the config file
		. "${Local_Repository}/SourceFile.sh" "${DIR_STATIC}/CheckConfig.sh"

		# Start of Timezone Block
		# Set Timezone non interactive ( Only if SETUP = NoInteraction), else: Ask directly for it.
		sudo timedatectl set-timezone "${Timezone[Continent]}/${Timezone[City]}"
		# timedatectl status
		# End: Set Timezone'
	fi


	if [ "$SETUP" = "SimpleSetup" ]; then
		# Simple Setup has been choosen. Change the most required settings.
		SetupServerMethod[NoInteraction]=0
		SetupServerMethod[SimpleSetup]=1
		SetupServerMethod[AdvancedSetup]=0

		. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/AddUserQuestions.sh"

		. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/DataDiskQuestions.sh"
	fi


	if [ "$SETUP" = "AdvancedSetup" ]; then
		# Advanced Setup has been choosen. Ask the user all available questions which have not been displayed yet.
		SetupServerMethod[NoInteraction]=0
		SetupServerMethod[SimpleSetup]=0
		SetupServerMethod[AdvancedSetup]=1

		. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/AddUserQuestions.sh"

		. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/DataDiskQuestions.sh"

		. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/TimezoneQuestions.sh"

		. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/KeyboardLayoutQuestions.sh"

		. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/BestMirrorQuestions.sh"

		. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/WebserverQuestions.sh"

		. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/DatabaseQuestions.sh"

		. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/NextcloudAppsQuestions.sh"

		. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/OfficeQuestions.sh"

		. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/CommunicationQuestions.sh"

		#. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/Redis.sh"

		#. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/Fail2ban.sh"

		#. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/SSL.sh"

		#. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/Security.sh"

		#. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/ModSecurity.sh"

		#. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/StaticIP.sh"

		#. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/SecureSSH.sh"
		
	fi

	## Display Warnings and messages?
	# Open Port 443 usw.

	###############################################################################################
	###############################################################################################
	###############################################################################################

	## Execute the needed scripts in the right order.

	echo "Here is a List of scripts that will be executed now."
	printf " - %s\n" "${workflow[@]}"

	any_key "Press any key to execute the scripts. Press CTRL+C to abort"
	
	# Set flag, that main script is running.
	DoNotEdit[MainAlreadyRunning]=1
	
	# Save config to file because it has changed
	. "${Local_Repository}/SourceFile.sh" "${DIR_STATIC}/UpdateConfigFile.sh" "config.cfg"
	

	# Write the workflow array to a file
	printf "%s\n" "${workflow[@]}" > workflow.txt
	
	# Check if dpkg or apt is running
	is_process_running apt
	is_process_running dpkg

	## Install needed packages

	# install_if_not curl	# witzlos, da vorher schon curl benötigt wird...

	install_if_not lshw

	install_if_not net-tools

	# Install needed network
	install_if_not netplan.io
	install_if_not network-manager

	# Test RAM size (2GB min) + CPUs (min 1) (Only if Office or Fulltextsearch? Or change the limits dynamicly?
	ram_check 2 Nextcloud
	cpu_check 1 Nextcloud

	# Check distrobution and version
	check_distro_version
	check_universe

	# Check if key is available
	if ! wget -q -T 10 -t 2 "$NCREPO" > /dev/null; then
		msg_box "Nextcloud repo ($NCREPO) is not available, exiting..."
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

else
	echo "Main has already been executed once. This is why we do not display the questions again."
fi

# Process the scripts / Continue processing the scripts (if e.g. the adduser.sh has rerun the main.sh script)
. "${Local_Repository}/SourceFile.sh" "process_queue.sh" "workflow.txt"

## Clear downloads
# . "${Local_Repository}/SourceFile.sh" "cleanup.sh"
