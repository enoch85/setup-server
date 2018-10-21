#!/bin/bash
if [ -z "$subshell_active" ]
then
	Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
	Github_Branch="master"
	UseLocalFiles=1	# This variable is for developement purposes, so that we don't have to push changes in a file to github befor testing it.
	Local_Repository=/home/georg/github/ggeorgg/setup-server
	sudo wget -O "${Local_Repository}/SourceFile.sh" "${Github_Repository}/${Github_Branch}/SourceFile.sh"
	# Include functions (download the config file and read it to arrays)
	. SourceFile.sh "lib.sh"

	subshell_active=1
	
	## Questions
	. SourceFile.sh "${Local_Repository}/${DIR_Questions}/AddUserQuestions.sh"
	
fi

if [ "$SUDO_USER" = "root" ]
then
	# creating a new user is mandatory 
	SudoUser[Adduser]=1
else
	echo "You are not the root user"
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
