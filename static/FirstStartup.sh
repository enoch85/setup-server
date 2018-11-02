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
	# . "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/AddUserQuestions.sh"
	
fi


# Check network
if network_ok
then
    printf "${Green}Online!${Color_Off}\n"
else
    echo "Setting correct interface..."
    [ -z "$IFACE" ] && IFACE=$(lshw -c network | grep "logical name" | awk '{print $3; exit}')
    # Set correct interface
cat <<-SETDHCP > "/etc/netplan/01-netcfg.yaml"
network:
  version: 2
  renderer: networkd
  ethernets:
    $IFACE:
      dhcp4: yes
      dhcp6: yes
SETDHCP
    check_command netplan apply
    check_command service network-manager restart
    ip link set "$IFACE" down
    wait
    ip link set "$IFACE" up
    wait
    check_command service network-manager restart
    echo "Checking connection..."
    sleep 3
    if ! nslookup github.com
    then
msg_box "Network NOT OK. You must have a working network connection to run this script
If you think that this is a bug, please report it to https://github.com/nextcloud/vm/issues."
    exit 1
    fi
fi

# Check if dpkg or apt is running
is_process_running apt
is_process_running dpkg

# download_static_script nextcloud
# download_static_script update-config
# download_le_script activate-ssl

if [ ! -f "${Local_Repository}/${DIR_STATIC}/index.php" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	wget -O "${Local_Repository}/${DIR_STATIC}/index.php" "${Github_Repository}/${Github_Branch}/${DIR_STATIC}/index.php"
fi

mv "${Local_Repository}/${DIR_STATIC}/index.php" "$HTML/index.php" && rm -f $HTML/html/index.html
chmod 750 $HTML/index.php && chown www-data:www-data $HTML/index.php

# Change 000-default to $WEB_ROOT
sed -i "s|DocumentRoot /var/www/html|DocumentRoot $HTML|g" /etc/apache2/sites-available/000-default.conf

# Make possible to see the welcome screen (without this php-fpm won't reach it)
sed -i '14i\    # http://lost.l-w.ca/0x05/apache-mod_proxy_fcgi-and-php-fpm/' /etc/apache2/sites-available/000-default.conf
sed -i '15i\   <FilesMatch "\.php$">' /etc/apache2/sites-available/000-default.conf
sed -i '16i\    <If "-f %{SCRIPT_FILENAME}">' /etc/apache2/sites-available/000-default.conf
sed -i '17i\      SetHandler "proxy:unix:/run/php/php7.2-fpm.nextcloud.sock|fcgi://localhost"' /etc/apache2/sites-available/000-default.conf
sed -i '18i\   </If>' /etc/apache2/sites-available/000-default.conf
sed -i '19i\   </FilesMatch>' /etc/apache2/sites-available/000-default.conf
sed -i '20i\    ' /etc/apache2/sites-available/000-default.conf

# Allow $UNIXUSER to run figlet script
# chown "$UNIXUSER":"$UNIXUSER" "$SCRIPTS/nextcloud.sh"

# Pretty URLs
echo "Setting RewriteBase to \"/\" in config.php..."
chown -R www-data:www-data $NCPATH
occ_command config:system:set overwrite.cli.url --value="http://localhost/"
occ_command config:system:set htaccess.RewriteBase --value="/"
occ_command maintenance:update:htaccess
# Secure permissions # Do we need this again here?
. "${Local_Repository}/SourceFile.sh" "${DIR_STATIC}/setup_secure_permissions_nextcloud.sh"

# Generate new SSH Keys # Why do we need it?
# https://www.cyberciti.biz/faq/howto-regenerate-openssh-host-keys/
# I don't need it, just necessary for distributing a VM
# printf "\nGenerating new SSH keys for the server...\n"
# rm -v /etc/ssh/ssh_host_*
# dpkg-reconfigure openssh-server
