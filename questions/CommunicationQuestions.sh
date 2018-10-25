
if [ "$MAIN_SETUP" -eq "0"] || [ "${SetupServerMethod[AdvancedSetup]}" -eq "1" ]; then
	COMMUNICATION=$(whiptail --title "Communication" --radiolist --separate-output \
	"Choose your communication system\nSelect by pressing the spacebar"  \
	"$WT_HEIGHT" "$WT_WIDTH" 3 \
	"Talk"    "${CommunicationDescriptions[Talk]}" "${Communication[Talk]}" \
	"SpreedMe" "${CommunicationDescriptions[SpreedMe]}" "${Communication[SpreedMe]}" \
	"DoNotInstall" "" "OFF" \
	3>&1 1>&2 2>&3)

	exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi
	clear

	case "$COMMUNICATION" in
		Talk)
			Communication[Talk]=1
			Communication[SpreedMe]=0
		;;		
		SpreedMe)
			Communication[Talk]=0
			Communication[SpreedMe]=1
		;;
		*)
			
		;;
	esac
fi
