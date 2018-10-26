#!/bin/bash
if [ -z "$MAIN_SETUP" ]
then
	Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
	Github_Branch="master"
	UseLocalFiles=1	# This variable is for developement purposes, so that we don't have to push changes in a file to github befor testing it.
	Local_Repository="/home/georg/github/ggeorgg/setup-server"
	if [ ! -f "${Local_Repository}/SourceFile.sh" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	wget -O "${Local_Repository}/SourceFile.sh" "${Github_Repository}/${Github_Branch}/SourceFile.sh"
	fi
	# Include functions (download the config file and read it to arrays)
	. "${Local_Repository}/SourceFile.sh" "lib.sh"

	MAIN_SETUP=0
		
	## Questions
	. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/DataDiskQuestions.sh"
	
fi



LABEL_=ncdata
# create folder if it does not exist (with the correct permissions?)
if [ ! -d "${DataDisk[DataDirectory]}" ]; then
	sudo mkdir -p "${DataDisk[DataDirectory]}"
fi

case "${DataDisk[Location]}" in 
	SystemDisk)
		# NC Data will be put on in the choosen folder
		echo "SystemDisk"
	;;
	
	DifferentDevice)
		# Append "/dev/ to each line
		SELECTEDDEVICES=$(echo ${DataDisk[Devices]} | tr ' ' '\n')
		SELECTEDDEVICES=$(printf "$SELECTEDDEVICES" | sed 's#^#/dev/#')

		# Convert to Array
		# Save current IFS
		SAVEIFS=$IFS
		# Change IFS to new line. 
		IFS=$'\n'
		# Create Array from whiptail output
		SELECTEDDEVICES=($SELECTEDDEVICES)
		# Restore IFS
		IFS=$SAVEIFS
		
		echo "${SELECTEDDEVICES[@]}"

		#sudo vgremove DATA -y

		## Create LVM System for ncdata

		# Initialize Partitions as Physical Volumes
		for seldev in "${SELECTEDDEVICES[@]}"
		do
		check_command sudo pvcreate "$seldev"
		done

		# Create Volume Group 
		check_command sudo vgcreate DATA "${SELECTEDDEVICES[@]}"

		# Create Logical Volume
		check_command sudo lvcreate -l 60%FREE -n NCDATA DATA

		case "${DataDisk[DataDiskFormat]}" in
			EXT4)
				sudo mkfs.ext4 /dev/DATA/NCDATA
				sudo mount /dev/DATA/NCDATA "${DataDisk[DataDirectory]}"
						
			;;
			ZFS)
				install_if_not "zfsutils-linux"

				DISKTYPE=/dev/DATA/NCDATA

				if zpool list | grep "$LABEL_" > /dev/null
				then
					check_command sudo zpool destroy "$LABEL_"
				fi
				check_command sudo wipefs -a -f "$DISKTYPE"
				sleep 0.5
				check_command sudo zpool create -f -o ashift=12 "$LABEL_" "$DISKTYPE"
				check_command sudo zpool set failmode=continue "$LABEL_"
				check_command sudo zfs set mountpoint="${DataDisk[DataDirectory]}" "$LABEL_"
				check_command sudo zfs set compression=lz4 "$LABEL_"
				check_command sudo zfs set sync=standard "$LABEL_"
				check_command sudo zfs set xattr=sa "$LABEL_"
				check_command sudo zfs set primarycache=all "$LABEL_"
				check_command sudo zfs set atime=off "$LABEL_"
				check_command sudo zfs set recordsize=128k "$LABEL_"
				check_command sudo zfs set logbias=latency "$LABEL_"
			;;
			*)
				
			;;
		esac

	# umount if mounted
	# umount /mnt/* &> /dev/null

	;;
	*)
	
	;;
esac	



	# umount /dev/sdb*
	# umount /dev/sdc*
	# wipefs -a -f /dev/sdb
	# wipefs -a -f /dev/sdc

	# check if device is already initialized as a physical volume