: '
# Start of Data disk Block - Old
msg_box "You will now see a list with available devices. 
Choose the device where you want to put your nextcloud data.
Attention, the selected devices will be completly erased!"
lsblk
read -e -p "Enter the drive for the nextcloud data:" -i "${DataDisk[Devices]}" DEVICE
DataDisk[Devices]="$DEVICE"

# End: Data disk Block - Old'

if [ "$(is_this_installed dialog)" -eq "0" ]; then
	# dialog is needed! 
	# https://www.ubuntuupdates.org/pm/dialog
	# This is the one for Ubuntu 18.04:
	curl -L http://security.ubuntu.com/ubuntu/pool/universe/d/dialog/dialog_1.3-20171209-1_amd64.deb -o "${Local_Repository}/dialog_1.3-20171209-1_amd64.deb" 
	# wget -O "${Local_Repository}/dialog_1.3-20171209-1_amd64.deb" http://security.ubuntu.com/ubuntu/pool/universe/d/dialog/dialog_1.3-20171209-1_amd64.deb
	# https://unix.stackexchange.com/questions/159094/how-to-install-a-deb-file-by-dpkg-i-or-by-apt
	sudo apt install ./dialog_1.3-20171209-1_amd64.deb
	# delete dialog afterward? Delete the .deb file afterward? Maybe in the cleanup file?
fi

DataDisk[Location]=$(whiptail --title "Nextcloud data location" --radiolist --separate-output \
"Do you want to format one or more devices to put your data on or do you just want to have your data on your system disk?\nSelect by pressing the spacebar"  \
"$WT_HEIGHT" "$WT_WIDTH" 2 \
"SystemDisk"      "You will have to choose a folder." "ON" \
"DifferentDevice" "You will have to choose one or more disks." "OFF" \
3>&1 1>&2 2>&3)

exit_status=$?; if [ $exit_status = 1 ]; then exit; fi
clear

case "${DataDisk[Location]}" in 
	SystemDisk)

msg_box "Choose where you want to put your nextcloud data.
Use  tab  or  arrow keys to move between the windows. Within the directory window, \
use the up/down arrow keys to scroll the current selection. Use the space-bar to copy the \
current selection into the text-entry window.

Typing  any  printable characters switches focus to the text-entry window, entering that \
character as well as scrolling the directory window to the closest match.

You also can first navigate to a directory an then type in name for a new directory.

Use a carriage return or the 'OK' button to accept the current value in the text-entry window and exit."
					  
		LINES=20
		COLUMNS=40
		DefaultDirectory="/home/$(who am i | awk '{print $1;}')/ncdata"
		NCDATADIRECTORY=$(dialog --stdout --title "Please choose a directory for your Nextcloud data" --dselect $DefaultDirectory  $LINES $COLUMNS)

		exit_status=$?; if [ $exit_status = 1 ]; then exit; fi
		
		# Check if current user has write permissions to this folder? If not let the user try again?
		
		# create folder if it does not exist (with the correct permissions!)
		if [ ! -d "$NCDATADIRECTORY" ]; then
			sudo mkdir -p "$NCDATADIRECTORY"
		fi
		
		DataDisk[DataDirectory]="$NCDATADIRECTORY"
		
	;;
	DifferentDevice)

		AvailableDEVICES=$(lsblk | grep "disk" | awk '{print $1}')

		# Save current IFS
		SAVEIFS=$IFS
		# Change IFS to new line. 
		IFS=$'\n'
		# Create Array from whiptail output
		AvailableDEVICES=($AvailableDEVICES)
		# Restore IFS
		IFS=$SAVEIFS

		# configinput='sdb sdc'
		SELECTEDDEVICES=$(echo ${DataDisk[Devices]} | tr " " "\n")
		# Append "/dev/ to each line
		# SELECTEDDEVICES=$(printf "$SELECTEDDEVICES" | sed 's#^#/dev/#')

		# Convert to Array
		# Save current IFS
		SAVEIFS=$IFS
		# Change IFS to new line. 
		IFS=$'\n'
		# Create Array from whiptail output
		SELECTEDDEVICES=($SELECTEDDEVICES)
		# Restore IFS
		IFS=$SAVEIFS

		# echo ${AvailableDEVICES[@]}
		# echo ${SELECTEDDEVICES[@]}

		for idx in "${AvailableDEVICES[@]}"; do
			skip=
			for j in "${SELECTEDDEVICES[@]}"; do
				# echo "idx = j: $idx = $j"
				[[ $idx == $j ]] && { skip=1; DEVICES_WHIPTAILTABLE+=("$idx" ""  "ON" ); break; }	
			done
			[[ -n $skip ]] || DEVICES_WHIPTAILTABLE+=("$idx" ""  "OFF" )
		done

		SELECTEDDEVICES=$(whiptail --title "Nextcloud data device" --checklist --separate-output \
		"Select the devices where you want to put your data on. \n(De-)Select by pressing the spacebar" \
		"$WT_HEIGHT" "$WT_WIDTH" 11 \
		"${DEVICES_WHIPTAILTABLE[@]}" \
		3>&1 1>&2 2>&3)

		exit_status=$?; if [ $exit_status = 1 ]; then exit; fi
		clear

		SELECTEDDEVICES=$(echo $SELECTEDDEVICES | tr '\n' ' ')

		DataDisk[Devices]="$SELECTEDDEVICES"
		
		
msg_box "Choose now where you want to mount the device(s).
Use  tab  or  arrow keys to move between the windows. Within the directory window, \
use the up/down arrow keys to scroll the current selection. Use the space-bar to copy the \
current selection into the text-entry window.

Typing  any  printable characters switches focus to the text-entry window, entering that \
character as well as scrolling the directory window to the closest match.

You also can first navigate to a directory an then type in name for a new directory.

Use a carriage return or the 'OK' button to accept the current value in the text-entry window and exit."
					  
		LINES=20
		COLUMNS=40
		DefaultDirectory="/mnt/ncdata"
		NCMountPoint=$(dialog --stdout --title "Please choose the mount directory for your Nextcloud data" --dselect $DefaultDirectory  $LINES $COLUMNS)

		exit_status=$?; if [ $exit_status = 1 ]; then exit; fi
		
		# Check if current user has write permissions to this folder? If not let the user try again?
		
		# create folder if it does not exist (with the correct permissions!)
		if [ ! -d "$NCMountPoint" ]; then
			sudo mkdir -p "$NCMountPoint"
		fi
		
		DataDisk[DataDirectory]="$NCMountPoint"
		
	;;
	*)
	
	;;
esac

if [ "$MAIN_SETUP" -eq "0" ] || [ "${SetupServerMethod[AdvancedSetup]}" -eq "1" ]; then

	FILESYSTEM=$(whiptail --title "Database" --radiolist --separate-output \
	"Choose your database managment system\nSelect by pressing the spacebar"  \
	"$WT_HEIGHT" "$WT_WIDTH" 2 \
	"EXT4"    "           " "OFF" \
	"ZFS" "           " "ON" \
	3>&1 1>&2 2>&3)

	exit_status=$?; if [ $exit_status = 1 ]; then exit; fi
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
