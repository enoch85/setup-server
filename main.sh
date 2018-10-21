#!/bin/bash
# MAIN_SETUP needs to be set here to prevent the functions.sh import to set subshell_active=1
MAIN_SETUP=1


# The next lines needs to be included and executed in each subfile if variable "MAIN_SETUP" does not exist or is 0
Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
Github_Branch="master"
UseLocalFiles=0	# This variable is for developement purposes, so that we don't have to push changes in a file to github befor testing it.
Local_Repository="/home/georg/github/ggeorgg/setup-server"
wget -O "${Local_Repository}/SourceFile.sh" "${Github_Repository}/${Github_Branch}/SourceFile.sh"
# Include functions (download the config file and read it to arrays)
. SourceFile.sh "lib.sh"

###############################################################################################
###############################################################################################
###############################################################################################


workflow=()
workflow+=("${Local_Repository}/${DIR_STATIC}/adduser.sh")
# workflow+=("${DIR_STATIC}/format-device.sh")
# workflow+=("${DIR_STATIC}/Setup-Webserver.sh")
# workflow[0]="SetupWebserver"
# workflow[1]="SetupDatabase"
# workflow[2]="SetupCloud"
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

. SourceFile.sh "${DIR_Questions}/SetupQuestions.sh"

## Edit ${CONFIG} file according to the users wishes

if [ "$SETUP" -eq "0" ]; then
SetupServerMethod[NoInteraction]=1
SetupServerMethod[SimpleSetup]=0
SetupServerMethod[AdvancedSetup]=0

# Start of Timezone Block
# Set Timezone non interactive ( Only if SETUP = NoInteraction), else: Ask directly for it.
sudo timedatectl set-timezone "${Timezone[Continent]}/${Timezone[City]}"
# timedatectl status
# End: Set Timezone'
fi

if [ "$SETUP" -gt "0" ]; then
# Simple Setup has been choosen. Change the most required settings.
SetupServerMethod[NoInteraction]=0
SetupServerMethod[SimpleSetup]=1
SetupServerMethod[AdvancedSetup]=0


. SourceFile.sh "${DIR_Questions}/DataDiskQuestions.sh"

fi


if [ "$SETUP" -gt "1" ]; then
# Advanced Setup has been choosen. Ask the user all available questions which have not been displayed yet.
SetupServerMethod[NoInteraction]=0
SetupServerMethod[SimpleSetup]=0
SetupServerMethod[AdvancedSetup]=1

. SourceFile.sh "${DIR_Questions}/TimezoneQuestions.sh"

. SourceFile.sh "${DIR_Questions}/AddUserQuestions.sh"

. SourceFile.sh "${DIR_Questions}/DatabaseQuestions.sh"

. SourceFile.sh "${DIR_Questions}/NextcloudAppsQuestions.sh"

. SourceFile.sh "${DIR_Questions}/OfficeQuestions.sh"

. SourceFile.sh "${DIR_Questions}/CommunicationQuestions.sh"
fi

## Display Warnings and messages?
# Open Port 443 usw.

###############################################################################################
###############################################################################################
###############################################################################################

. SourceFile.sh "${DIR_STATIC}/UpdateConfigFile.sh"

## Execute the needed scripts in the right order.

echo "Here is a List of scripts that will be executed now."
echo "${workflow[@]}"

any_key "Press any key to execute the scripts. Press CTRL+C to abort"

whoami
for script in "${workflow[@]}"; do
	. SourceFile.sh "${script}"
done
whoami

## Clear downloads
rm "${Local_Repository}/config.cfg"