#!/bin/bash
Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
Github_Branch="master"

if [ -z "$subshell_active" ]
then

	# Install curl if not existing
	if [ "$(dpkg-query -W -f='${Status}' "curl" 2>/dev/null | grep -c "ok installed")" == "1" ]
	then
		echo "curl OK"
	else
		apt update -q4
		apt install curl -y
	fi

	# Include functions (download the config file and read it to arrays)
	source <(curl -sL "${Github_Repository}/${Github_Branch}/lib.sh")
	subshell_active=1
fi

if [ "$SUDO_USER" = "root" ]
then
	# creating a new user is mandatory 
	SudoUser[Adduser]=1
fi

if [ "${SudoUser[Adduser]}" -eq 1 ]
then
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
	exit
	
	adduser --disabled-password --gecos "" "$NEWUSER"
	sudo usermod -aG sudo "$NEWUSER"
	usermod -s /bin/bash "$NEWUSER"
	while true
	do
		sudo passwd "$NEWUSER" && break
	done
	# Execute script with the new user?
	# sudo -u "$NEWUSER" sudo bash "$1"
	exit
fi
