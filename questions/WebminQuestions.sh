if (whiptail --title "Webmin" --yesno "Install Webmin?" 8 78); then
    # echo "User selected Yes, exit status was $?."
	Miscelangelous[SETUP_Webmin]=1
else
    # echo "User selected No, exit status was $?."
	Miscelangelous[SETUP_Webmin]=0
fi
