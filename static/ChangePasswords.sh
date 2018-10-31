# Change password
printf "${Color_Off}\n"
echo "For better security, change the system user password for [$(getent group sudo | cut -d: -f4 | cut -d, -f1)]"
any_key "Press any key to change password for system user..."
while true
do
    sudo passwd "$(getent group sudo | cut -d: -f4 | cut -d, -f1)" && break
done
echo
clear
NCADMIN=$(occ_command user:list | awk '{print $3}')
printf "${Color_Off}\n"
echo "For better security, change the Nextcloud password for [$NCADMIN]"
echo "The current password for $NCADMIN is [$NCPASS]"
any_key "Press any key to change password for Nextcloud..."
while true
do
    sudo -u www-data php "$NCPATH"/occ user:resetpassword "$NCADMIN" && break
done
clear
