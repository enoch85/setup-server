
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
			
		;;
	esac
fi
