# MAIN_SETUP needs to be set here to prevent the functions.sh import to set subshell_active=1
MAIN_SETUP=1

# Include functions (download the config file and read it to arrays)
source lib.sh

###############################################################################################
###############################################################################################
###############################################################################################


workflow=()
workflow+=("${DIR_STATIC}/adduser.sh")
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

source "${DIR_Questions}/SetupQuestions.sh"

## Edit ${CONFIG} file according to the users wishes

if [ "$SETUP" -eq "0" ]
then
SetupServerMethod[NoInteraction]=1
SetupServerMethod[SimpleSetup]=0
SetupServerMethod[AdvancedSetup]=0

# Start of Timezone Block
# Set Timezone non interactive ( Only if SETUP = NoInteraction), else: Ask directly for it.
sudo timedatectl set-timezone "${Timezone[Continent]}/${Timezone[City]}"
# timedatectl status
# End: Set Timezone'
fi

if [ "$SETUP" -gt "0" ]
then
# Simple Setup has been choosen. Change the most required settings.
SetupServerMethod[NoInteraction]=0
SetupServerMethod[SimpleSetup]=1
SetupServerMethod[AdvancedSetup]=0

source "${DIR_Questions}/DataDiskQuestions.sh"

fi


if [ "$SETUP" -gt "1" ]
then
# Advanced Setup has been choosen. Ask the user all available questions which have not been displayed yet.
SetupServerMethod[NoInteraction]=0
SetupServerMethod[SimpleSetup]=0
SetupServerMethod[AdvancedSetup]=1

source "${DIR_Questions}/TimezoneQuestions.sh"

source "${DIR_Questions}/DatabaseQuestions.sh"

source "${DIR_Questions}/NextcloudAppsQuestions.sh"

source "${DIR_Questions}/OfficeQuestions.sh"

source "${DIR_Questions}/CommunicationQuestions.sh"
fi

## Display Warnings and messages?
# Open Port 443 usw.





###############################################################################################
###############################################################################################
###############################################################################################

# Create new temporary config file (empty it, when it already exists) for the other scripts
> "${CONFIG_FILE_PATH}.tmp"

# https://stackoverflow.com/a/35543417
for idx in "${arrays[@]}"; do
    declare -n temp="$idx"
	printf "[${idx}]\n" >> "${CONFIG_FILE_PATH}.tmp"
	for i in "${!temp[@]}"
	do 
		printf "${i}=${temp[$i]}\n" >> "${CONFIG_FILE_PATH}.tmp"
	done
	printf "\n" >> "${CONFIG_FILE_PATH}.tmp"
done

# Replace old config file by new one
cat "${CONFIG_FILE_PATH}.tmp" > "$CONFIG_FILE_PATH"


# Delete config.tmp
rm "${CONFIG_FILE_PATH}.tmp"


## Execute the needed scripts in the right order.

echo "Here is a List of scripts that will be executed now."
echo "${workflow[@]}"

any_key "Press any key to execute the scripts. Press CTRL+C to abort"

# for script in "${workflow[@]}"
# do

# download_static_script adduser
# bash $SCRIPTS/adduser.sh "nextcloud_install_production.sh"
# rm $SCRIPTS/adduser.sh
# bash "${script}"
# done


