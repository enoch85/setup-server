#!/bin/bash
if [ -z "$subshell_active" ]
then
	Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
	Github_Branch="master"
	UseLocalFiles=1	# This variable is for developement purposes, so that we don't have to push changes in a file to github befor testing it.
	Local_Repository="/home/georg/github/ggeorgg/setup-server"
	sudo wget -O "${Local_Repository}/SourceFile.sh" "${Github_Repository}/${Github_Branch}/SourceFile.sh"
	# Include functions (download the config file and read it to arrays)
	. "${Local_Repository}/SourceFile.sh" "lib.sh"

	subshell_active=1
		
	## Questions
	. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/AddUserQuestions.sh"
	
fi

if [ "${SudoUser[Adduser]}" -eq 1 ]
then
msg_box "We will create the new user with sudo permissions now.\n
You will be prompted to choose a password"
	sudo adduser --disabled-password --gecos "" "${SudoUser[Username]}"
	sudo usermod -aG sudo "${SudoUser[Username]}"
	sudo usermod -s /bin/bash "${SudoUser[Username]}"
	while true
	do
		sudo passwd "${SudoUser[Username]}" && break
	done
	# Execute script with the new user?
	sudo su "${SudoUser[Username]}"
	echo "user switched"
	# sudo -u "${SudoUser[Username]}"  sudo bash "$1"
	# exit
fi
