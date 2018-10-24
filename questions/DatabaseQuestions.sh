DATABASE=$(whiptail --title "Database" --radiolist --separate-output \
"Choose your database managment system\nSelect by pressing the spacebar"  \
"$WT_HEIGHT" "$WT_WIDTH" 2 \
"MariaDB"    "           " ${DBMS[MariaDB]} \
"PostgreSQL" "           " ${DBMS[PostgreSQL]} \
3>&1 1>&2 2>&3)

exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi
clear

case "$DATABASE" in
	MariaDB)
		DBMS[MariaDB]=1
		DBMS[PostgreSQL]=0
	;;		
	PostgreSQL)
		DBMS[MariaDB]=0
		DBMS[PostgreSQL]=1
	;;
	*)
		
	;;
esac