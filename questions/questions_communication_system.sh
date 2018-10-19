CONFIG[communication_system]=$(whiptail --title "Communication" \
--radiolist \
--separate-output \
"Choose your communication system\nSelect by pressing the spacebar"  \
"$WT_HEIGHT" "$WT_WIDTH" 3 \
"talk"    	"${CommunicationDescriptions[Talk]}" 		$([ ${CONFIG[communication_system]} = 'talk' ] && echo 1 || echo 0) \
"spreedme" 	"${CommunicationDescriptions[SpreedMe]}" 	$([ ${CONFIG[communication_system]} = 'spreedme' ] && echo 1 || echo 0) \
"no_communication_system" "" "OFF" \
3>&1 1>&2 2>&3)

exit_status=$?; if [ $exit_status = 1 ]; then exit; fi; unset $exit_status
clear
