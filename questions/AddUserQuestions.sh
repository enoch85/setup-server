# Only relevant for 
# [ "${SetupServerMethod[SimpleSetup]}" -eq "1" ] 
# [ "${SetupServerMethod[AdvancedSetup]}" -eq "1" ]
# [ "${SetupServerMethod[NoInteraction]}" -eq "1" ] will never see this file

askquestion=1 # Default value for standalone script


if [ "$MAIN_SETUP" = 1 ] && [ "$(who am i | awk '{print $1;}')" = "root" ]; then
	SudoUser[Adduser]=1
	askquestion=0
	msg_box "Creating a new user is mandatory because we won't run the script as pure root user."
elif [ "$MAIN_SETUP" = 1 ] && ! [ -z "$((sudo -v) 2>&1)" ]; then
	SudoUser[Adduser]=1
	askquestion=0
	msg_box "You haved switched the user to root user ('sudo su') and executed the command 'sudo main.sh'. This is not possible."
elif [ "$SUDO_USER" = "root" ]; then
	msg_box "Creating a new user is mandatory because the user needs to be in sudoers group."
elif [ "$MAIN_SETUP" = 1 ] && [ "${SetupServerMethod[SimpleSetup]}" -eq "1" ]; then
	# Do not ask for user creation because we want to keep the SimpleSetup as simple as possible
	# This may also be the default config value so we do not need it here.
	SudoUser[Adduser]=0
	askquestion=0
elif [ "$MAIN_SETUP" = 1 ] && [ "${SetupServerMethod[AdvancedSetup]}" -eq "1" ]; then
	# Let user decide to add a new user
	askquestion=1
fi

# Set current user as SudoUser in config file
SudoUser[Username]=$SUDO_USER

if [ "$askquestion" -eq "1" ]; then
ADDSUDOUSER=$(whiptail --title "Add sudo user" --radiolist --separate-output \
"Choose if you want to create a new user within sudo user group.\nSelect by pressing the spacebar"  \
"$WT_HEIGHT" "$WT_WIDTH" 3 \
"Yes" "" "${SudoUser[Adduser]}" \
"No"  "" $([ ${SudoUser[Adduser]} == 0 ] && echo 1 || echo 0) \
3>&1 1>&2 2>&3)

exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi
clear

case "$ADDSUDOUSER" in
	Yes)
		SudoUser[Adduser]=1
	;;		
	No)
		SudoUser[Adduser]=0
	;;
	*)
		
	;;
esac
fi

if [ "${SudoUser[Adduser]}" -eq 1 ]; then
	while true
		read -e -r -p "Enter name of the new user: " -i "${SudoUser[Username]}" NEWUSER
		if [ -z "$NEWUSER" ] || [ "$NEWUSER" == "root" ]; then
			echo "User must not be blank or \"root\""
		else
			break
		fi
	do
	echo "You chose \"$NEWUSER\" as username."
	done
	SudoUser[Username]="$NEWUSER"
else 
	echo "No user will be added."
fi
