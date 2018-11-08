CONFIG[webserver]=$(whiptail --title "Webserver" --radiolist --separate-output \
"Choose your office system\nSelect by pressing the spacebar"  \
"$WT_HEIGHT" "$WT_WIDTH" 2 \
"apache2"    	"" 		$([ ${CONFIG[webserver]} = 'apache2' ] && echo 1 || echo 0) \
"nginx" 		"" 		$([ ${CONFIG[webserver]} = 'nginx' ] && echo 1 || echo 0) \
3>&1 1>&2 2>&3)

exit_status=$?; if [ $exit_status = 1 ]; then exit; fi; unset $exit_status
clear

if (whiptail --title "Protocol" --yesno "Use HTTP2 Protocol instead of HTTP1?" 8 78); then
    # echo "User selected Yes, exit status was $?."
	Apache[EnableHTTP2]=1
else
    # echo "User selected No, exit status was $?."
	Apache[EnableHTTP2]=0
fi
