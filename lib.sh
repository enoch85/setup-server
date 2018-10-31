#!/bin/bash

# Global parameters
. "${Local_Repository}/SourceFile.sh" "GlobalParameter.sh"

# Config already available? If not, load it from Github.
if [ ! -f "${Local_Repository}/config.cfg" ]; then
	# It is not the main file that has been called but the subscript because the config file does not exist
    echo "Config file not found - Getting the default one from github.com!"
	wget -O "${Local_Repository}/config.cfg" "${Github_Repository}/${Github_Branch}/config.cfg"
fi

# Read config file to arrays
. "${Local_Repository}/SourceFile.sh" "readconfig2array.sh"

### Begin of functions
function msg_box() {
local PROMPT="$1"
    whiptail --msgbox "${PROMPT}" "$WT_HEIGHT" "$WT_WIDTH"
}

function any_key() {
    local PROMPT="$1"
    read -r -sn 1 -p "$(printf "%b" "${Green}${PROMPT}${Color_Off}")";echo
}

function ask_yes_or_no() {
    read -r -p "$1 ([y]es or [N]o): "
    case ${REPLY,,} in
        y|yes)
            echo "yes"
        ;;
        *)
            echo "no"
        ;;
    esac
}

function is_this_installed() {
if [ "$(dpkg-query -W -f='${Status}' "${1}" 2>/dev/null | grep -c "ok installed")" == "1" ]
then
    # echo "${1} is installed."
	echo 1
else
	echo 0
fi
}

function install_if_not () {
if [[ "$(is_this_installed "${1}")" -eq "0" ]]
then
    sudo apt update -q4 & spinner_loading && sudo apt install "${1}" -y
fi
}

function check_command() {
  if ! "$@";
  then
     printf "${IRed}Sorry but something went wrong. Please report this issue to $ISSUES and include the output of the error message. Thank you!${Color_Off}\n"
     echo "$* failed"
    exit 1
  fi
}

function spinner_loading() {
    pid=$!
    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null
    do
        i=$(( (i+1) %4 ))
        printf "\r[${spin:$i:1}] " # Add text here, something like "Please be paitent..." maybe?
        sleep .1
    done
}

function restart_webserver() {
	check_command systemctl restart apache2
	if which php7.2-fpm > /dev/null
	then
		check_command systemctl restart php7.2-fpm.service
	fi
}

# is_root() {
    # if [[ "$EUID" -ne 0 ]]
    # then
        # return 1
    # else
        # return 0
    # fi
# }

# Test RAM size 
# Call it like this: ram_check [amount of min RAM in GB] [for which program]
# Example: ram_check 2 Nextcloud
function ram_check() {
mem_available="$(awk '/MemTotal/{print $2}' /proc/meminfo)"
if [ "${mem_available}" -lt "$((${1}*1002400))" ]
then
    printf "${Red}Error: ${1} GB RAM required to install ${2}!${Color_Off}\n" >&2
    printf "${Red}Current RAM is: ("$((mem_available/1002400))" GB)${Color_Off}\n" >&2
    sleep 3
    msg_box "If you want to bypass this check you could do so by commenting out (# before the line) 'ram_check X' in the script that you are trying to run.
    
    In nextcloud_install_production.sh you can find the check somewhere around line #34. 
    
    Please notice that things may be veery slow and not work as expeced. YOU HAVE BEEN WARNED!"
    exit 1
else
    printf "${Green}RAM for ${2} OK! ("$((mem_available/1002400))" GB)${Color_Off}\n"
fi
}

# Test number of CPU
# Call it like this: cpu_check [amount of min CPU] [for which program]
# Example: cpu_check 2 Nextcloud
function cpu_check() {
nr_cpu="$(nproc)"
if [ "${nr_cpu}" -lt "${1}" ]
then
    printf "${Red}Error: ${1} CPU required to install ${2}!${Color_Off}\n" >&2
    printf "${Red}Current CPU: ("$((nr_cpu))")${Color_Off}\n" >&2
    sleep 3
    exit 1
else
    printf "${Green}CPU for ${2} OK! ("$((nr_cpu))")${Color_Off}\n"
fi
}

# Example: occ_command 'maintenance:mode --on'
function occ_command() {
	check_command sudo -u www-data php "$NCPATH"/occ "$@";
}

# Check if process is runnnig: is_process_running dpkg
function is_process_running() {
	PROCESS="$1"

	while :
	do
		RESULT=$(pgrep "${PROCESS}")

		if [ "${RESULT:-null}" = null ]; then
				break
		else
				echo "${PROCESS} is running. Waiting for it to stop..."
				sleep 10
		fi
	done
}

function check_distro_version() {
	# Check Ubuntu version
	echo "Checking server OS and version..."
	if [ "$DISTRIBUTORID" = "Ubuntu" ] && [ "$CODENAME" = "bionic" ]; then
		OS=1
	fi

	if [ "$OS" != 1 ]; then
	echo "Ubuntu Server 'bionic' is required to run this script.
	Please install that distro and try again.

	You can find the download link here: https://www.ubuntu.com/download/server"
		exit 1
	fi

	if ! version 18.04 "$RELEASE" 18.04.4; then
	echo "Ubuntu version $RELEASE must be between 18.04 - 18.04.4"
		exit 1
	else
		echo "Your Ubuntu version is good. We will now proceed!"
	fi
}


function version(){
    local h t v

    [[ $2 = "$1" || $2 = "$3" ]] && return 0

    v=$(printf '%s\n' "$@" | sort -V)
    h=$(head -n1 <<<"$v")
    t=$(tail -n1 <<<"$v")

    [[ $2 != "$h" && $2 != "$t" ]]
}

# Check universe reposiroty
function check_universe() {
if [ "$UNIV" = "universe" ]
then
        echo "Seems that required repositories are ok."
else
        echo "Adding required repo (universe)."
        add-apt-repository universe
fi
}

function network_ok() {
    echo "Testing if network is OK..."
    if ! service network-manager restart > /dev/null
    then
        service networking restart > /dev/null
    fi
    sleep 2
    if wget -q -T 20 -t 2 http://github.com -O /dev/null & spinner_loading
    then
        return 0
    else
        return 1
    fi
}

function calculate_max_children() {
# Calculate max_children depending on RAM
# Tends to be between 30-50MB
average_php_memory_requirement=50
available_memory=$(awk '/MemAvailable/ {printf "%d", $2/1024}' /proc/meminfo)
export PHP_FPM_MAX_CHILDREN=$((available_memory/average_php_memory_requirement))

echo "Automatically configures pm.max_children for php-fpm..."
if [ $PHP_FPM_MAX_CHILDREN -lt 8 ]
then
msg_box "The current max_children value available to set is $PHP_FPM_MAX_CHILDREN, and with that value PHP-FPM won't function properly.
The minimum value is 8, and the value is calculated depening on how much RAM you have left to use in the system.

The absolute minimum amount of RAM required to run the VM is 2 GB, but we recomend 4 GB.

You now have two choices:
1. Import this VM again, raise the amount of RAM with at least 1 GB, and then run this script again,
   installing it in the same way as you did before.
2. Import this VM again without raising the RAM, but don't install any of the following apps:
   1) Collabora
   2) OnlyOffice
   3) Full Text Search

This script will now exit. 
The installation was not successful, sorry for the inconvenience.

If you think this is a bug, please report it to $ISSUES"
exit 1
else
    echo "pm.max_children was set to $PHP_FPM_MAX_CHILDREN"
fi
}

function download_verify_nextcloud_stable() {
##### ????????????????? it's working but there is some warning message:unsafe ownership on homedir '/home/georg/.gnupg'
# sudo chown -R root:root /home/georg/.gnupg 
rm -f "$HTML/$STABLEVERSION.tar.bz2"
wget -q -T 10 -t 2 "$NCREPO/$STABLEVERSION.tar.bz2" -P "$HTML"
mkdir -p "$GPGDIR"
wget -q "$NCREPO/$STABLEVERSION.tar.bz2.asc" -P "$GPGDIR"
chmod -R 600 "$GPGDIR"
gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$OpenPGP_fingerprint"
gpg --verify "$GPGDIR/$STABLEVERSION.tar.bz2.asc" "$HTML/$STABLEVERSION.tar.bz2"
rm -r "$GPGDIR"
rm -f releases
# sudo chown -R georg:georg /home/georg/.gnupg 
}

function configure_max_upload() {
# Increase max filesize (expects that changes are made in $PHP_INI)
# Here is a guide: https://www.techandme.se/increase-max-file-size/
echo "Setting max_upload size in PHP..."
# Copy settings from .htaccess to user.ini. beacuse we run php-fpm. Documented here: https://docs.nextcloud.com/server/13/admin_manual/installation/source_installation.html#php-fpm-configuration-notes
cp -fv "$NCPATH/.htaccess" "$NCPATH/.user.ini"
# Do the acutal change
sed -i 's/  php_value upload_max_filesize.*/# php_value upload_max_filesize 511M/g' "$NCPATH"/.user.ini
sed -i 's/  php_value post_max_size.*/# php_value post_max_size 511M/g' "$NCPATH"/.user.ini
sed -i 's/  php_value memory_limit.*/# php_value memory_limit 512M/g' "$NCPATH"/.user.ini
}



function install_and_enable_app() {
# Download and install $1
if [ ! -d "$NC_APPS_PATH/$1" ]
then
    echo "Installing $1..."
    occ_command app:install "$1"
fi

# Enable $1
if [ -d "$NC_APPS_PATH/$1" ]
then
    occ_command app:enable "$1"
    chown -R www-data:www-data "$NC_APPS_PATH"
fi
}





# Install certbot (Let's Encrypt)
function install_certbot() {
certbot --version 2> /dev/null
LE_IS_AVAILABLE=$?
if [ $LE_IS_AVAILABLE -eq 0 ]
then
    certbot --version 2> /dev/null
else
    echo "Installing certbot (Let's Encrypt)..."
    apt update -q4 & spinner_loading
    install_if_not software-properties-common
    add-apt-repository ppa:certbot/certbot -y
    apt update -q4 & spinner_loading
    install_if_not certbot
    apt update -q4 & spinner_loading
    apt dist-upgrade -y
fi
}

# Let's Encrypt for subdomains
function le_subdomain() {
a2dissite 000-default.conf
service apache2 reload
certbot certonly --standalone --pre-hook "service apache2 stop" --post-hook "service apache2 start" --agree-tos --rsa-key-size 4096 -d "$SUBDOMAIN"
}

# Check if port is open # check_open_port 443 domain.example.com
function check_open_port() {
# Check to see if user already has nmap installed on their system
if [ "$(dpkg-query -s nmap 2> /dev/null | grep -c "ok installed")" == "1" ]
then
    NMAPSTATUS=preinstalled
fi

apt update -q4 & spinner_loading
if [ "$NMAPSTATUS" = "preinstalled" ]
then
      echo "nmap is already installed..."
else
    apt install nmap -y
fi

# Check if $1 is open using nmap, if not notify the user
if [ "$(nmap -sS -p "$1" "$WANIP4" | grep -c "open")" == "1" ]
then
  printf "${Green}Port $1 is open on $WANIP4!${Color_Off}\n"
  if [ "$NMAPSTATUS" = "preinstalled" ]
  then
    echo "nmap was previously installed, not removing."
  else
    apt remove --purge nmap -y
  fi
else
  whiptail --msgbox "Port $1 is not open on $WANIP4. We will do a second try on $2 instead." "$WT_HEIGHT" "$WT_WIDTH"
  if [[ "$(nmap -sS -PN -p "$1" "$2" | grep -m 1 "open" | awk '{print $2}')" = "open" ]]
  then
      printf "${Green}Port $1 is open on $2!${Color_Off}\n"
      if [ "$NMAPSTATUS" = "preinstalled" ]
      then
        echo "nmap was previously installed, not removing."
      else
        apt remove --purge nmap -y
      fi
  else
      whiptail --msgbox "Port $1 is not open on $2. Please follow this guide to open ports in your router: https://www.techandme.se/open-port-80-443/" "$WT_HEIGHT" "$WT_WIDTH"
      any_key "Press any key to exit... "
      if [ "$NMAPSTATUS" = "preinstalled" ]
      then
        echo "nmap was previously installed, not removing."
      else
        apt remove --purge nmap -y
      fi
      exit 1
  fi
fi
}
