# Download and validate Nextcloud package
check_command download_verify_nextcloud_stable

if [ ! -f "$HTML/$STABLEVERSION.tar.bz2" ]
then
msg_box "Aborting,something went wrong with the download of $STABLEVERSION.tar.bz2"
    exit 1
fi

# Extract package
tar -xjf "$HTML/$STABLEVERSION.tar.bz2" -C "$HTML" & spinner_loading
rm "$HTML/$STABLEVERSION.tar.bz2"

# Secure permissions
. "${Local_Repository}/SourceFile.sh" "${DIR_STATIC}/setup_secure_permissions_nextcloud.sh"

# Install Nextcloud
cd "$NCPATH"
NCDATA="${DataDisk[DataDirectory]}"
NCUSER"${SudoUser[Username]}"

occ_command maintenance:install \
--data-dir="$NCDATA" \
--database=pgsql \
--database-name=nextcloud_db \
--database-user="$NCUSER" \
--database-pass="$PGDB_PASS" \
--admin-user="$NCUSER" \
--admin-pass="$NCPASS"
echo
echo "Nextcloud version:"
occ_command status
sleep 3
echo

# Prepare cron.php to be run every 15 minutes
crontab -u www-data -l | { cat; echo "*/15  *  *  *  * php -f $NCPATH/cron.php > /dev/null 2>&1"; } | crontab -u www-data -

# Change values in php.ini (increase max file size)
# max_execution_time
sed -i "s|max_execution_time =.*|max_execution_time = 3500|g" $PHP_INI
# max_input_time
sed -i "s|max_input_time =.*|max_input_time = 3600|g" $PHP_INI
# memory_limit
sed -i "s|memory_limit =.*|memory_limit = 512M|g" $PHP_INI
# post_max
sed -i "s|post_max_size =.*|post_max_size = 1100M|g" $PHP_INI
# upload_max
sed -i "s|upload_max_filesize =.*|upload_max_filesize = 1000M|g" $PHP_INI

# Set max upload in Nextcloud .user.ini
configure_max_upload

# Set SMTP mail
occ_command config:system:set mail_smtpmode --value="smtp"

# Set logrotate
occ_command config:system:set log_rotate_size --value="10485760"












# Needed? What do we need it for?
# Install Figlet
install_if_not figlet