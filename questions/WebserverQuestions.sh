WEBSERVER=$(whiptail --title "OFFICE" --radiolist --separate-output \
"Choose your office system\nSelect by pressing the spacebar"  \
"$WT_HEIGHT" "$WT_WIDTH" 3 \
"Apache2"    "" "${Webserver[Apache2]}" \
"NGINX" "" "${Webserver[NGINX]}" \
3>&1 1>&2 2>&3)

exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi
clear

case "$WEBSERVER" in
	Apache2)
		Webserver[Apache2]=1
		Webserver[NGINX]=0
	;;		
	NGINX)
		Webserver[Apache2]=0
		Webserver[NGINX]=1
	;;
	*)
		
	;;
esac


# If you cannot understand this, read Bash_Shell_Scripting#if_statements again.
if (whiptail --title "Protocol" --yesno "Use HTTP2 Protocol instead of HTTP1?" 8 78); then
    # echo "User selected Yes, exit status was $?."
	Apache[EnableHTTP2]=1
else
    # echo "User selected No, exit status was $?."
	Apache[EnableHTTP2]=0
fi
