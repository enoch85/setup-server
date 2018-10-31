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

for app in "${!NextcloudApps[@]}"; do
	case "$app" in 
		PreviewGenerator)
			echo "Installation of $app not implemented yet!"
		;;

		Bitwarden)
			echo "Installation of $app not implemented yet!"
		;;
		
		Keeweb)
			echo "Installation of $app not implemented yet!"
		;;
		
		FullTextSearch)
			echo "Installation of $app not implemented yet!"
		;;
		
		*)
			install_and_enable_app "$app"
		;;
	esac			
done
