if (whiptail --title "Webmin" --yesno "Install Webmin?" 8 78); then
    # echo "User selected Yes, exit status was $?."
	Miscelangelous[SETUP_Webmin]=1
else
    # echo "User selected No, exit status was $?."
	Miscelangelous[SETUP_Webmin]=0
fi

if (whiptail --title "SETUP_Netdata" --yesno "Install SETUP_Netdata?" 8 78); then
    # echo "User selected Yes, exit status was $?."
	Miscelangelous[SETUP_Netdata]=1
else
    # echo "User selected No, exit status was $?."
	Miscelangelous[SETUP_Netdata]=0
fi

if (whiptail --title "SETUP_Security" --yesno "Install SETUP_Security?" 8 78); then
    # echo "User selected Yes, exit status was $?."
	Miscelangelous[SETUP_Security]=1
else
    # echo "User selected No, exit status was $?."
	Miscelangelous[SETUP_Security]=0
fi

if (whiptail --title "SETUP_ModSecurity" --yesno "Install SETUP_ModSecurity?" 8 78); then
    # echo "User selected Yes, exit status was $?."
	Miscelangelous[SETUP_ModSecurity]=1
else
    # echo "User selected No, exit status was $?."
	Miscelangelous[SETUP_ModSecurity]=0
fi

if (whiptail --title "SETUP_STATIC_IP" --yesno "Install SETUP_STATIC_IP?" 8 78); then
    # echo "User selected Yes, exit status was $?."
	Miscelangelous[SETUP_STATIC_IP]=1
else
    # echo "User selected No, exit status was $?."
	Miscelangelous[SETUP_STATIC_IP]=0
fi

if (whiptail --title "SETUP_Adminer" --yesno "Install SETUP_Adminer?" 8 78); then
    # echo "User selected Yes, exit status was $?."
	Miscelangelous[SETUP_Adminer]=1
else
    # echo "User selected No, exit status was $?."
	Miscelangelous[SETUP_Adminer]=0
fi

if (whiptail --title "SETUP_Fail2ban" --yesno "Install SETUP_Fail2ban?" 8 78); then
    # echo "User selected Yes, exit status was $?."
	Miscelangelous[SETUP_Fail2ban]=1
else
    # echo "User selected No, exit status was $?."
	Miscelangelous[SETUP_Fail2ban]=0
fi

if (whiptail --title "SETUP_SECURE_SSH" --yesno "Install SETUP_SECURE_SSH?" 8 78); then
    # echo "User selected Yes, exit status was $?."
	Miscelangelous[SETUP_SECURE_SSH]=1
else
    # echo "User selected No, exit status was $?."
	Miscelangelous[SETUP_SECURE_SSH]=0
fi

if (whiptail --title "SETUP_Redis" --yesno "Install SETUP_Redis?" 8 78); then
    # echo "User selected Yes, exit status was $?."
	Miscelangelous[SETUP_Redis]=1
else
    # echo "User selected No, exit status was $?."
	Miscelangelous[SETUP_Redis]=0
fi

