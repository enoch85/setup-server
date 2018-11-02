
if [ "$MAIN_SETUP" -eq "0"] || [ "${SetupServerMethod[AdvancedSetup]}" -eq "1" ]; then

	OFFICE=$(whiptail --title "OFFICE" --radiolist --separate-output \
	"Choose your office system\nSelect by pressing the spacebar"  \
	"$WT_HEIGHT" "$WT_WIDTH" 3 \
	"OnlyOffice"    "${OfficeDescriptions[OnlyOffice]}" "${Office[OnlyOffice]}" \
	"Collabora" "${OfficeDescriptions[Collabora]}" "${Office[Collabora]}" \
	"DoNotInstall" "" "OFF" \
	3>&1 1>&2 2>&3)

	exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi
	clear

	case "$OFFICE" in
		OnlyOffice)
			Office[OnlyOffice]=1
			Office[Collabora]=0
		;;		
		Collabora)
			Office[OnlyOffice]=0
			Office[Collabora]=1
		;;
		*)
			Office[OnlyOffice]=0
			Office[Collabora]=0	
		;;
	esac
fi

if [ "$OFFICE" != "DoNotInstall" ]; then
	SEPARATEMACHINE=$(whiptail --title "OFFICE" --radiolist --separate-output \
	"Choose the method how you want to install your office suite.\nSelect by pressing the spacebar"  \
	"$WT_HEIGHT" "$WT_WIDTH" 2 \
	"SeparateMachine"    "" "${Office[SeparateMachine]}" \
	"SameMachine"        "" $([ ${Office[SeparateMachine]} == 0 ] && echo 1 || echo 0) \
	3>&1 1>&2 2>&3)

	exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi
	clear	
	
	case "$SEPARATEMACHINE" in
		SeparateMachine)
			Office[SeparateMachine]=1
		;;		
		SameMachine)
			Office[SeparateMachine]=0
		;;
		*)

		;;
	esac	
fi
