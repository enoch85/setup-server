
if [ "$SUDO_USER" = "root" ] && [ "$MAIN_SETUP" = 1 ]
then
	# creating a new user is mandatory 
	SudoUser[Adduser]=1
fi

ADDSUDOUSER=$(whiptail --title "Add sudo user" --radiolist --separate-output \
"Choose if you want to create a new user with in sudo user group.\nSelect by pressing the spacebar"  \
"$WT_HEIGHT" "$WT_WIDTH" 3 \
"Yes" "" "ON" \
"No"  "" "OFF" \
3>&1 1>&2 2>&3)

exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi

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


if [ "${SudoUser[Adduser]}" -eq 1 ]; then
	while true
		read -e -r -p "Enter name of the new user: " -i "${SudoUser[Username]}" NEWUSER
		if [ -z "$NEWUSER" ] || [ "$NEWUSER" == "root" ]
		then
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
