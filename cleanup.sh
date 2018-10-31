UNIXUSER="${SudoUser[Username]}"

# Cleanup 1
occ_command maintenance:repair
# rm -f "$SCRIPTS/ip.sh"
# rm -f "$SCRIPTS/change_db_pass.sh"
# rm -f "$SCRIPTS/test_connection.sh"
# rm -f "$SCRIPTS/instruction.sh"
# rm -f "$NCDATA/nextcloud.log"
# rm -f "$SCRIPTS/nextcloud-startup-script.sh"
# find /root "/home/$UNIXUSER" -type f \( -name '*.sh*' -o -name '*.html*' -o -name '*.tar*' -o -name '*.zip*' \) -delete
# sed -i "s|instruction.sh|nextcloud.sh|g" "/home/$UNIXUSER/.bash_profile"

rm "${Local_Repository}/config.cfg"
rm "${Local_Repository}/workflow.txt"
sudo rm "/etc/sudoers.d/custom"
sudo rm "/etc/systemd/system/getty@tty1.service.d/override.conf"
sudo rm "/home/georg/.bash_profile"

truncate -s 0 \
    /root/.bash_history \
    "/home/$UNIXUSER/.bash_history" \
    /var/spool/mail/root \
    "/var/spool/mail/$UNIXUSER" \
    /var/log/apache2/access.log \
    /var/log/apache2/error.log \
    /var/log/cronjobs_success.log
	
# Upgrade system
# clear
# echo "System will now upgrade..."
# bash $SCRIPTS/update.sh	
	
apt autoremove -y
apt autoclean