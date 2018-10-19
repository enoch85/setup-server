if [[ "yes" == $(ask_yes_or_no "Do you want to install SSL?") ]]; then
    Miscelangelous[SETUP_LetsEncrypt_SSL]=1
fi
