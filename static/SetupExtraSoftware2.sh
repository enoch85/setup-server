# Fixes https://github.com/nextcloud/vm/issues/58
a2dismod status	# Kann das auch schon an einer anderen stelle gemacht werden, sodass der Webserver nicht schon wieder neu gestartet werden muss?
restart_webserver

# Increase max filesize (expects that changes are made in $PHP_INI)
# Here is a guide: https://www.techandme.se/increase-max-file-size/
configure_max_upload

# Extra configurations
whiptail --title "Extra configurations" --checklist --separate-output "Choose what you want to configure\nSelect by pressing the spacebar" "$WT_HEIGHT" "$WT_WIDTH" 4 \
"Security" "(Add extra security based on this http://goo.gl/gEJHi7)" OFF \
"SecureSSH" "TBD" OFF \
"ModSecurity" "(Add ModSecurity for Apache2" OFF \
"Static IP" "(Set static IP in Ubuntu with netplan.io)" OFF 2>results

while read -r -u 9 choice
do
    case $choice in
        "Security")
            clear
            run_static_script security
        ;;
		
        "SecureSSH")
            clear
			echo "TBD"
        ;;		
        
        "ModSecurity")
            clear
            run_static_script modsecurity
        ;;

        "Static IP")
            clear
            run_static_script set_static_ip
        ;;

        *)
        ;;
    esac
done 9< results
rm -f results

# Calculate max_children after all apps are installed
calculate_max_children
check_command sed -i "s|pm.max_children.*|pm.max_children = $PHP_FPM_MAX_CHILDREN|g" $PHP_POOL_DIR/nextcloud.conf
restart_webserver

# # Set trusted domain in config.php
# if [ -f "$SCRIPTS"/trusted.sh ] 
# then
    # bash "$SCRIPTS"/trusted.sh # Can be done with an occ command???
    # rm -f "$SCRIPTS"/trusted.sh
# fi

# Prefer IPv6
sed -i "s|precedence ::ffff:0:0/96  100|#precedence ::ffff:0:0/96  100|g" /etc/gai.conf
