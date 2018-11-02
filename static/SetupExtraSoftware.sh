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



if [ "${Miscelangelous[SETUP_Webmin]}" -eq "1" ]; then
	echo "SETUP_Webmin TBD"
fi

if [ "${Miscelangelous[SETUP_Netdata]}" -eq "1" ]; then
	echo "SETUP_Netdata TBD"
fi

if [ "${Miscelangelous[SETUP_Adminer]}" -eq "1" ]; then
	echo "SETUP_Adminer TBD"
fi

if [ "${Miscelangelous[SETUP_Fail2ban]}" -eq "1" ]; then
	echo "SETUP_Fail2ban TBD"
fi

if [ "${SecureSSH[SETUP_SECURE_SSH]}" -eq "1" ]; then
	echo "SETUP_SECURE_SSH TBD"
fi

if [ "${Office[OnlyOffice]}" -eq "1" ]; then
	. "${Local_Repository}/SourceFile.sh" "${DIR_STATIC}/SetupOnlyOffice.sh"
fi



# # Install Apps
# whiptail --title "Which apps do you want to install?" --checklist --separate-output "Automatically configure and install selected apps\nSelect by pressing the spacebar" "$WT_HEIGHT" "$WT_WIDTH" 4 \
# "Fail2ban" "(Extra Bruteforce protection)   " OFF \
# "Adminer" "(PostgreSQL GUI)       " OFF \
# "Netdata" "(Real-time server monitoring)       " OFF \
# "Collabora" "(Online editing [2GB RAM])   " OFF \
# "OnlyOffice" "(Online editing [4GB RAM])   " OFF \
# "Bitwarden" "(Password manager) - NOT STABLE   " OFF \
# "FullTextSearch" "(Elasticsearch for Nextcloud [2GB RAM])   " OFF \
# "PreviewGenerator" "(Pre-generate previews)   " OFF \
# "Talk" "(Nextcloud Video calls and chat)   " OFF \
# "Spreed.ME" "(3rd-party Video calls and chat)   " OFF 2>results

# while read -r -u 9 choice
# do
    # case $choice in
        # Fail2ban)
            # clear
            # run_app_script fail2ban
        # ;;
        
        # Adminer)
            # clear
            # run_app_script adminer
        # ;;
        
        # Netdata)
            # clear
            # run_app_script netdata
        # ;;
        
        # OnlyOffice)
            # clear
            # run_app_script onlyoffice
        # ;;
        
        # Collabora)
            # clear
            # run_app_script collabora
        # ;;

        # Bitwarden)
            # clear
            # run_app_script tmbitwarden
        # ;;
        
        # FullTextSearch)
            # clear
           # run_app_script fulltextsearch
        # ;;             
        
        # PreviewGenerator)
            # clear
           # run_app_script previewgenerator
        # ;;   

        # Talk)
            # clear
            # run_app_script talk
        # ;;
        
        # Spreed.ME)
            # clear
            # run_app_script spreedme
        # ;;

        # *)
        # ;;
    # esac
# done 9< results
# rm -f results
# clear
