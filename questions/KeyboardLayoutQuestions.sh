# Set keyboard layout
clear
echo "Current keyboard layout is $(localectl status | grep "Layout" | awk '{print $3}')"
if [[ "yes" == $(ask_yes_or_no "Do you want to change keyboard layout?") ]]; then
    dpkg-reconfigure keyboard-configuration
    clear
fi
