msg_box "The following script will install a trusted
SSL certificate through Let's Encrypt.

It's recommended to use SSL together with Nextcloud.
Please open port 80 and 443 to this servers IP before you continue.

More information can be found here:
https://www.techandme.se/open-port-80-443/"

# Let's Encrypt
if [[ "yes" == $(ask_yes_or_no "Do you want to install SSL?") ]]
then
    bash $SCRIPTS/activate-ssl.sh
else
    echo
    echo "OK, but if you want to run it later, just type: sudo bash $SCRIPTS/activate-ssl.sh"
    any_key "Press any key to continue..."
fi
clear
