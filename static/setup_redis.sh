#!/bin/bash
if [ -z "$MAIN_SETUP" ]
then
	Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
	Github_Branch="master"
	UseLocalFiles=1	# This variable is for developement purposes, so that we don't have to push changes in a file to github befor testing it.
	Local_Repository="/home/georg/github/ggeorgg/setup-server"
	if [ ! -f "${Local_Repository}/source_file.sh" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	wget -O "${Local_Repository}/source_file.sh" "${Github_Repository}/${Github_Branch}/source_file.sh"
	fi
	# Include functions (download the config file and read it to arrays)
	. "${Local_Repository}/source_file.sh" "lib.sh"

	MAIN_SETUP=0
		
	## Questions
	# . "${Local_Repository}/source_file.sh" "${DIR_Questions}/AddUserQuestions.sh"
	
fi

# Install Redis
install_if_not php7.2-dev
pecl channel-update pecl.php.net
if ! yes no | pecl install -Z redis
then
    msg_box "PHP module installation failed"
exit 1
else
    printf "${Green}\nPHP module installation OK!${Color_Off}\n"
fi
install_if_not redis-server

# Set globally doesn't work for some reason
# touch /etc/php/7.0/mods-available/redis.ini
# echo 'extension=redis.so' > /etc/php/7.0/mods-available/redis.ini
# phpenmod redis
# Setting direct to apache2 works
echo 'extension=redis.so' >> $PHP_INI
restart_webserver

# Prepare for adding redis configuration
sed -i "s|);||g" $NCPATH/config/config.php

# Add the needed config to Nextclouds config.php
cat <<ADD_TO_CONFIG >> $NCPATH/config/config.php
  'memcache.local' => '\\OC\\Memcache\\Redis',
  'filelocking.enabled' => true,
  'memcache.distributed' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' =>
  array (
    'host' => '$REDIS_SOCK',
    'port' => 0,
    'timeout' => 0.5,
    'dbindex' => 0,
    'password' => '$REDIS_PASS',
  ),
);
ADD_TO_CONFIG

## Redis performance tweaks ##
if ! grep -Fxq "vm.overcommit_memory = 1" /etc/sysctl.conf
then
    echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
fi

# Disable THP
if ! grep -Fxq "never" /sys/kernel/mm/transparent_hugepage/enabled
then
    echo "never" > /sys/kernel/mm/transparent_hugepage/enabled
fi

# Raise TCP backlog
#if ! grep -Fxq "net.core.somaxconn" /proc/sys/net/core/somaxconn
#then
#    sed -i "s|net.core.somaxconn.*||g" /etc/sysctl.conf
#    sysctl -w net.core.somaxconn=512
#    echo "net.core.somaxconn = 512" >> /etc/sysctl.conf
#fi
sed -i "s|# unixsocket .*|unixsocket $REDIS_SOCK|g" $REDIS_CONF
sed -i "s|# unixsocketperm .*|unixsocketperm 777|g" $REDIS_CONF
sed -i "s|^port.*|port 0|" $REDIS_CONF
sed -i "s|# requirepass .*|requirepass $REDIS_PASS|g" $REDIS_CONF
sed -i 's|# rename-command CONFIG ""|rename-command CONFIG ""|' $REDIS_CONF
redis-cli SHUTDOWN

# Secure Redis
chown redis:root /etc/redis/redis.conf
chmod 600 /etc/redis/redis.conf

apt update -q4 & spinner_loading
apt autoremove -y
apt autoclean
