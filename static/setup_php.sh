#!/bin/bash
if [ -z "$MAIN_SETUP" ]; then
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
	. "${Local_Repository}/source_file.sh" "${DIR_Questions}/WebserverQuestions.sh"
	
fi

# Install PHP 7.2
apt update -q4 & spinner_loading
check_command apt install -y \
    php7.2-fpm \
    php7.2-intl \
    php7.2-ldap \
    php7.2-imap \
    php7.2-gd \
    php7.2-pgsql \
    php7.2-curl \
    php7.2-xml \
    php7.2-zip \
    php7.2-mbstring \
    php7.2-soap \
    php7.2-smbclient \
    php7.2-imagick \
    php7.2-json \
    php7.2-gmp \
    php7.2-bz2 \
    php-pear \
    libmagickcore-6.q16-3-extra
    
# Enable php-fpm
a2enconf php7.2-fpm

if 	[ "${Webserver[Apache2]}" -eq "1" ] && [ "${Apache[EnableHTTP2]}" -eq "1" ]; then
	echo "Enabling HTTP/2 server wide..."
	# https://httpd.apache.org/docs/2.4/mod/mod_http2.html
	# https://techwombat.com/enable-http2-apache-ubuntu-16-04/
cat << HTTP2_ENABLE > "$HTTP2_CONF"
<IfModule http2_module>
    Protocols h2 h2c http/1.1
    H2Direct on
</IfModule>
HTTP2_ENABLE
	echo "$HTTP2_CONF was successfully created"
	a2enmod http2
	restart_webserver
fi

# Calculate max_children for php-fpm (this will be run in the end of the startup script as well)
calculate_max_children

# Set up a php-fpm pool with a unixsocket
cat << POOL_CONF > "$PHP_POOL_DIR/nextcloud.conf"
[Nextcloud]
user = www-data
group = www-data
listen = /run/php/php7.2-fpm.nextcloud.sock
listen.owner = www-data
listen.group = www-data
pm = dynamic
;; max_children is set dynamically with calculate_max_children()
pm.max_children = $PHP_FPM_MAX_CHILDREN
pm.start_servers = 3
pm.min_spare_servers = 2
pm.max_spare_servers = 3
pm.max_requests = 500
env[HOSTNAME] = $(hostname -f)
env[PATH] = /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
security.limit_extensions = .php
php_admin_value [cgi.fix_pathinfo] = 1
POOL_CONF

# Disable the idling example pool.
mv $PHP_POOL_DIR/www.conf $PHP_POOL_DIR/www.conf.backup

# Enable the new php-fpm config
restart_webserver









# Additional??? Always needed? Or only when VM running?
# Install VM-tools
install_if_not open-vm-tools