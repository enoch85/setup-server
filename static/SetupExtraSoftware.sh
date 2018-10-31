# Install Apps
whiptail --title "Which apps do you want to install?" --checklist --separate-output "Automatically configure and install selected apps\nSelect by pressing the spacebar" "$WT_HEIGHT" "$WT_WIDTH" 4 \
"Fail2ban" "(Extra Bruteforce protection)   " OFF \
"Adminer" "(PostgreSQL GUI)       " OFF \
"Netdata" "(Real-time server monitoring)       " OFF \
"Collabora" "(Online editing [2GB RAM])   " OFF \
"OnlyOffice" "(Online editing [4GB RAM])   " OFF \
"Bitwarden" "(Password manager) - NOT STABLE   " OFF \
"FullTextSearch" "(Elasticsearch for Nextcloud [2GB RAM])   " OFF \
"PreviewGenerator" "(Pre-generate previews)   " OFF \
"Talk" "(Nextcloud Video calls and chat)   " OFF \
"Spreed.ME" "(3rd-party Video calls and chat)   " OFF 2>results

while read -r -u 9 choice
do
    case $choice in
        Fail2ban)
            clear
            run_app_script fail2ban
        ;;
        
        Adminer)
            clear
            run_app_script adminer
        ;;
        
        Netdata)
            clear
            run_app_script netdata
        ;;
        
        OnlyOffice)
            clear
            run_app_script onlyoffice
        ;;
        
        Collabora)
            clear
            run_app_script collabora
        ;;

        Bitwarden)
            clear
            run_app_script tmbitwarden
        ;;
        
        FullTextSearch)
            clear
           run_app_script fulltextsearch
        ;;             
        
        PreviewGenerator)
            clear
           run_app_script previewgenerator
        ;;   

        Talk)
            clear
            run_app_script talk
        ;;
        
        Spreed.ME)
            clear
            run_app_script spreedme
        ;;

        *)
        ;;
    esac
done 9< results
rm -f results
clear
