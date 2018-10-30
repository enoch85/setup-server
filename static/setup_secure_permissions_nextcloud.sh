#!/bin/bash
if [ -z "$MAIN_SETUP" ]; then
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
	. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/WebserverQuestions.sh"
	
fi

htuser='www-data'
htgroup='www-data'
rootuser='root'

NCDATA="${DataDisk[DataDirectory]}"

printf "Creating possible missing Directories\n"
mkdir -p $NCPATH/data
mkdir -p $NCPATH/updater
mkdir -p $NCDATA

printf "chmod Files and Directories\n"
find ${NCPATH}/ -type f -print0 | xargs -0 chmod 0640
find ${NCPATH}/ -type d -print0 | xargs -0 chmod 0750

printf "chown Directories\n"
chown -R ${rootuser}:${htgroup} ${NCPATH}/
chown -R ${htuser}:${htgroup} ${NCPATH}/apps/
chown -R ${htuser}:${htgroup} ${NCPATH}/config/
chown -R ${htuser}:${htgroup} ${NCDATA}/
chown -R ${htuser}:${htgroup} ${NCPATH}/themes/
chown -R ${htuser}:${htgroup} ${NCPATH}/updater/

chmod +x ${NCPATH}/occ

printf "chmod/chown .htaccess\n"
if [ -f ${NCPATH}/.htaccess ]
then
    chmod 0644 ${NCPATH}/.htaccess
    chown ${rootuser}:${htgroup} ${NCPATH}/.htaccess
fi
if [ -f ${NCDATA}/.htaccess ]
then
    chmod 0644 ${NCDATA}/.htaccess
    chown ${rootuser}:${htgroup} ${NCDATA}/.htaccess
fi
