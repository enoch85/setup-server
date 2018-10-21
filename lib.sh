#!/bin/bash

# Global parameters
source SourceFile.sh "GlobalParameter.cfg"


subshell_active=0
# Config already available? If not, load it from Github.
if [ ! -f "$CONFIG_FILE_PATH" ]; then
	# It is not the main file that has been called but the subscript.
    echo "Config file not found - Getting the default one from github.com!"
	wget "${Github_Repository}/${Github_Branch}/config.cfg"
	if [ "$MAIN_SETUP -neq 1" ]; then
		subshell_active=1
	fi
fi

# Read config file to arrays
arrays=()
while read line; do 
    if [[ $line =~ ^"["(.+)"]"$ ]]; then 
        arrname=${BASH_REMATCH[1]}
        declare -A $arrname
		arrays+=("$arrname")
    elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then 
        declare ${arrname}[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
    fi
done < "$CONFIG_FILE_PATH"


### Begin of functions
function msg_box() {
local PROMPT="$1"
    whiptail --msgbox "${PROMPT}" "$WT_HEIGHT" "$WT_WIDTH"
}

function any_key() {
    local PROMPT="$1"
    read -r -sn 1 -p "$(printf "%b" "${Green}${PROMPT}${Color_Off}")";echo
}

function ask_yes_or_no() {
    read -r -p "$1 ([y]es or [N]o): "
    case ${REPLY,,} in
        y|yes)
            echo "yes"
        ;;
        *)
            echo "no"
        ;;
    esac
}

function is_this_installed() {
if [ "$(dpkg-query -W -f='${Status}' "${1}" 2>/dev/null | grep -c "ok installed")" == "1" ]
then
    echo "${1} is installed."
    exit 1
fi
}

function install_if_not () {
if [[ "$(is_this_installed "${1}")" != "${1} is installed." ]]
then
    apt update -q4 & spinner_loading && apt install "${1}" -y
fi
}

function check_command() {
  if ! "$@";
  then
     printf "${IRed}Sorry but something went wrong. Please report this issue to $ISSUES and include the output of the error message. Thank you!${Color_Off}\n"
     echo "$* failed"
    exit 1
  fi
}

function spinner_loading() {
    pid=$!
    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null
    do
        i=$(( (i+1) %4 ))
        printf "\r[${spin:$i:1}] " # Add text here, something like "Please be paitent..." maybe?
        sleep .1
    done
}