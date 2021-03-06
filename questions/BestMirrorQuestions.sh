# Check where the best mirrors are and update
clear
printf "Your current server repository is:  ${Cyan}%s${Color_Off}\n" "$REPO"
if [[ "yes" == $(ask_yes_or_no "Do you want to try to find a better mirror?") ]]; then
   echo "Locating the best mirrors..."
   apt update -q4 & spinner_loading
   apt install python-pip -y
   pip install \
       --upgrade pip \
       apt-select
    apt-select -m up-to-date -t 5 -c
    sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup && \
    if [ -f sources.list ]
    then
        sudo mv sources.list /etc/apt/
    fi
fi
