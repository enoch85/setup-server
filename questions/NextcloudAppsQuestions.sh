
for idx in "${!NextcloudApps[@]}"; do
	NC_APPS_WHIPTAILTABLE+=("$idx" "${NextcloudAppsDescriptions[$idx]}"  "${NextcloudApps[$idx]}" )
done

NC_APPS_ACTIVATED=$(whiptail --title "Nextcloud apps" --checklist --separate-output \
"Automatically configure and install selected apps\n(De-)Select by pressing the spacebar" \
"$WT_HEIGHT" "$WT_WIDTH" 11 \
"${NC_APPS_WHIPTAILTABLE[@]}" \
3>&1 1>&2 2>&3)

exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi
clear

# Save current IFS
SAVEIFS=$IFS
# Change IFS to new line. 
IFS=$'\n'
# Create Array from whiptail output
NC_APPS_ACTIVATED=($NC_APPS_ACTIVATED)
# Restore IFS
IFS=$SAVEIFS

NC_APPS_DEACTIVATED=()
for idx in "${!NextcloudApps[@]}"; do
	skip=
	for j in "${NC_APPS_ACTIVATED[@]}"; do
		[[ $idx == $j ]] && { skip=1; break; }	
	done
	[[ -n $skip ]] || NC_APPS_DEACTIVATED+=("$idx")
done

# Set value of selected apps to "install - 1"
for app in "${NC_APPS_ACTIVATED[@]}"
do
	echo "activated: $app"
	NextcloudApps[$app]=1
done

# Set value of not selected apps to "do not install - 0"
for app in "${NC_APPS_DEACTIVATED[@]}"
do
	echo "deactivated: $app"
	NextcloudApps[$app]=0	
done
