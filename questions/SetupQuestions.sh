## Simple/Recommended setup or Advanced/Expert setup
SETUP=$(whiptail --title "Setup your Server" \
--separate-output \
--radiolist "Choose the method how to setup your server\nSelect by pressing the spacebar" \
"$WT_HEIGHT" "$WT_WIDTH" 3 \
"NoInteraction"    "           " "${SetupServerMethod[NoInteraction]}" \
"SimpleSetup"      "           " "${SetupServerMethod[SimpleSetup]}" \
"AdvancedSetup"    "           " "${SetupServerMethod[AdvancedSetup]}" \
3>&1 1>&2 2>&3)

exitstatus=$?; if [ $exitstatus = 1 ]; then exit; fi
clear
