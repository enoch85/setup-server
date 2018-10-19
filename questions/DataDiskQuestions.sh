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
DEVICES_WHIPTAILTABLE+=("$dev" ""  "OFF" )
done

SELECTEDDEVICES=$(whiptail --title "Nextcloud apps" --checklist --separate-output \
"Automatically configure and install selected apps\n(De-)Select by pressing the spacebar" \
"$WT_HEIGHT" "$WT_WIDTH" 11 \
"${DEVICES_WHIPTAILTABLE[@]}" \
3>&1 1>&2 2>&3)

exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi


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

# End: Data disk Block - New'