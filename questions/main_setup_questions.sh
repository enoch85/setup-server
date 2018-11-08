CONFIG[setup_server_method]=$(whiptail --title "Setup your Server" \
--separate-output \
--radiolist \
"Choose the method how to setup your server\nSelect by pressing the spacebar" \
"$WT_HEIGHT" "$WT_WIDTH" 3 \
"no_interaction"    " " $([ ${CONFIG[setup_server_method]} = 'no_interaction' ] && echo 1 || echo 0) \
"simple_setup"      " " $([ ${CONFIG[setup_server_method]} = 'simple_setup' ] && echo 1 || echo 0) \
"advanced_setup"    " " $([ ${CONFIG[setup_server_method]} = 'advanced_setup' ] && echo 1 || echo 0) \
3>&1 1>&2 2>&3)

exit_status=$?; if [ $exit_status = 1 ]; then exit; fi; unset $exit_status
clear
