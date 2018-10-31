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

ROOT_PROFILE="/root/.bash_profile"

[ -f /root/.profile ] && rm -f /root/.profile # is this really needed? https://wiki.ubuntuusers.de/Umgebungsvariable/ : Existiert eine Datei ~/.bash_profile, so wird ~/.profile von der Bash (Standard-Shell) ignoriert. Auch Einstellungen in ~/.bashrc überschreiben in der Bash die Einstellungen aus ~/.profile. 


cat <<ROOT-PROFILE > "$ROOT_PROFILE"

# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]
then
    if [ -f ~/.bashrc ]
    then
        . ~/.bashrc
    fi
fi

if [ -x /var/scripts/nextcloud-startup-script.sh ]
then
    /var/scripts/nextcloud-startup-script.sh
fi

if [ -x /var/scripts/history.sh ]
then
    /var/scripts/history.sh
fi

mesg n

ROOT-PROFILE

# Add Aliases
{
echo "alias nextcloud_occ='sudo -u www-data php $NCPATH/occ'"
echo "alias run_update_nextcloud='bash $SCRIPTS/update.sh'"
} > /root/.bash_aliases

