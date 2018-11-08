CONFIG[office]=$(whiptail --title "OFFICE" \
--radiolist \
--separate-output \
"Choose your office system\nSelect by pressing the spacebar"  \
"$WT_HEIGHT" "$WT_WIDTH" 3 \
"only_office"    		"${OfficeDescriptions[OnlyOffice]}" 	$([ ${CONFIG[dbms]} = 'maria_db' ] && echo 1 || echo 0) \
"collabora_office" 		"${OfficeDescriptions[Collabora]}" 		$([ ${CONFIG[dbms]} = 'maria_db' ] && echo 1 || echo 0) \
"no_office_app" 		"" 										$([ ${CONFIG[dbms]} = 'maria_db' ] && echo 1 || echo 0) \
3>&1 1>&2 2>&3)

exit_status=$?; if [ $exit_status = 1 ]; then exit; fi; unset $exit_status
clear

if [ "${CONFIG[office]}" != "no_office_app" ]; then
	CONFIG[office_machine]=$(whiptail --title "OFFICE" \
	--radiolist \
	--separate-output \
	"Choose the method how you want to install your office suite.\nSelect by pressing the spacebar"  \
	"$WT_HEIGHT" "$WT_WIDTH" 2 \
	"separate_machine"    "" $([ ${CONFIG[office_machine]} = 'separate_machine' ] && echo 1 || echo 0) \
	"same_machine"        "" $([ ${CONFIG[office_machine]} = 'same_machine' ] && echo 1 || echo 0) \
	3>&1 1>&2 2>&3)

	exit_status=$?; if [ $exit_status = 1 ]; then exit; fi; unset $exit_status
	clear
fi
