: '
# Start of Data disk Block - Old
msg_box "You will now see a list with available devices. 
Choose the device where you want to put your nextcloud data.
Attention, the selected devices will be completly erased!"
lsblk
read -e -p "Enter the drive for the nextcloud data:" -i "${DataDisk[Devices]}" DEVICE
DataDisk[Devices]="$DEVICE"

# End: Data disk Block - Old'


# Start of Data disk Block - New

DataDisk[Location]=$(whiptail --title "Nextcloud data location" --radiolist --separate-output \
"Do you want to format one or more devices to put your data on or do you just want to have your data on your system disk?\nSelect by pressing the spacebar"  \
"$WT_HEIGHT" "$WT_WIDTH" 3 \
"SystemDisk"      "You will have to choose a folder later." "ON" \
"DifferentDevice" "You will have to choose one or more disks which will be wiped completly." "OFF" \
3>&1 1>&2 2>&3)

exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi
clear

echo "${DataDisk[@]}"
exit

# case "$COMMUNICATION" in
	# Talk)
		# Communication[Talk]=1
		# Communication[SpreedMe]=0
	# ;;		
	# SpreedMe)
		# Communication[Talk]=0
		# Communication[SpreedMe]=1
	# ;;
	# *)
		
	# ;;
# esac



DEVICES=$(lsblk | grep "disk" | awk '{print $1}')

# Save current IFS
SAVEIFS=$IFS
# Change IFS to new line. 
IFS=$'\n'
# Create Array from whiptail output
DEVICES=($DEVICES)
# Restore IFS
IFS=$SAVEIFS

for dev in "${DEVICES[@]}"
do
	if [ "${DataDisk[Devices]}" = "$dev" ]
	then
		DEVICES_WHIPTAILTABLE+=("$dev" ""  "ON" )
	else
		DEVICES_WHIPTAILTABLE+=("$dev" ""  "OFF" )
	fi
done

SELECTEDDEVICES=$(whiptail --title "Nextcloud data device" --checklist --separate-output \
"Select the devices where you want to put your data on. \n(De-)Select by pressing the spacebar" \
"$WT_HEIGHT" "$WT_WIDTH" 11 \
"${DEVICES_WHIPTAILTABLE[@]}" \
3>&1 1>&2 2>&3)

exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi
clear

# # Append "/dev/ to each line
# SELECTEDDEVICES=$(printf "$SELECTEDDEVICES" | sed 's#^#/dev/#')


# # Convert to Array
# # Save current IFS
# SAVEIFS=$IFS
# # Change IFS to new line. 
# IFS=$'\n'
# # Create Array from whiptail output
# SELECTEDDEVICES=($SELECTEDDEVICES)
# # Restore IFS
# IFS=$SAVEIFS


SELECTEDDEVICES=$(echo $SELECTEDDEVICES | tr '\n' ' ')

DataDisk[Devices]="$SELECTEDDEVICES"


if [ "${SetupServerMethod[AdvancedSetup]}" -eq "1" ]; then
############################

FILESYSTEM=$(whiptail --title "Database" --radiolist --separate-output \
"Choose your database managment system\nSelect by pressing the spacebar"  \
"$WT_HEIGHT" "$WT_WIDTH" 2 \
"EXT4"    "           " "OFF" \
"ZFS" "           " "ON" \
3>&1 1>&2 2>&3)

exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi
clear 

case "$FILESYSTEM" in
	EXT4)
		DataDisk[DataDiskFormat]=EXT4
	;;		
	ZFS)
		DataDisk[DataDiskFormat]=ZFS
	;;
	*)
		
	;;
esac

fi

# End: Data disk Block - New'