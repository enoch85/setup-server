CONFIG[dbms]=$(whiptail --title "Database" \
--separate-output \
--radiolist \
"Choose your database managment system\nSelect by pressing the spacebar"  \
"$WT_HEIGHT" "$WT_WIDTH" 2 \
"maria_db"    " " $([ ${CONFIG[dbms]} = 'maria_db' ] && echo 1 || echo 0) \
"postgre_sql" " " $([ ${CONFIG[dbms]} = 'postgre_sql' ] && echo 1 || echo 0) \
3>&1 1>&2 2>&3)

exit_status=$?; if [ $exit_status = 1 ]; then exit; fi; unset $exit_status
clear
