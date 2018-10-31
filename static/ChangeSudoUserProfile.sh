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
	# . "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/AddUserQuestions.sh"
	
fi

UNIXUSER="${SudoUser[Username]}"

UNIXUSER_PROFILE="/home/$UNIXUSER/.bash_profile"

rm "/home/$UNIXUSER/.profile"	# is this really needed? https://wiki.ubuntuusers.de/Umgebungsvariable/ : Existiert eine Datei ~/.bash_profile, so wird ~/.profile von der Bash (Standard-Shell) ignoriert. Auch Einstellungen in ~/.bashrc überschreiben in der Bash die Einstellungen aus ~/.profile. 

cat <<-UNIXUSER-PROFILE > "$UNIXUSER_PROFILE"
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.
# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022
# if running bash
if [ -n "$BASH_VERSION" ]
then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]
    then
        . "$HOME/.bashrc"
    fi
fi
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]
then
    PATH="$HOME/bin:$PATH"
fi
bash /var/scripts/instruction.sh
bash /var/scripts/history.sh
sudo -i

UNIXUSER-PROFILE

chown "$UNIXUSER:$UNIXUSER" "$UNIXUSER_PROFILE"
chown "$UNIXUSER:$UNIXUSER" "$SCRIPTS/history.sh"
chown "$UNIXUSER:$UNIXUSER" "$SCRIPTS/instruction.sh"

exit 0
