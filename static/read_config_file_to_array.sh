#### Read a config file and fills an array with a list of read configurations

###	Input parameter
##	Mandatory
#	$1: 	File location of config file to read in
#	$2:		Name of array that will be used to make a list of the declared arrays
## 	Optional
# 	None

### Dependencies (Scripts that need to be in place before using this one here)
#	None

###	Variables that must be set before using this file
#	None

###	Example usage
#	. "${Local_Repository}/source_file.sh" "read_config_file_to_array.sh" "config.cfg" "configXYZ"

###	Variables
[[ -z ${BGreen+x} ]] && BGreen='\e[1;32m'																		# Set default value if variable not set yet
[[ -z ${BRed+x} ]] && BRed='\e[1;31m'																			# Set default value if variable not set yet
[[ -z ${Color_Off+x} ]] && Color_Off='\e[0m'																	# Set default value if variable not set yet
[[ -z ${Local_Repository+x} ]] && Local_Repository="$HOME/setup-server"											# Set default value if variable not set yet
[[ -z ${Github_Repository+x} ]] && Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"	# Set default value if variable not set yet
[[ -z ${Github_Branch+x} ]] && Github_Branch="master"															# Set default value if variable not set yet

### Code

# Check if config file exists
if [ ! -f "${Local_Repository}/${1}" ]; then
	# printf "${BRed}%s${Color_Off}\n" "${Local_Repository}/${1} does not exist!"
	# exit
	
	printf "${BGreen}%s\n%s${Color_Off}\n" \
			"Info: The file '${Local_Repository}/${1}' does not exist." \
			"We will download the default one from github."	
			
	curl -sLf "${Github_Repository}/${Github_Branch}/${1}" --create-dirs -o "${Local_Repository}/${1}"

	exit_status=$?
	if [[ $exit_status != 0 ]]; then
		printf "${BRed}Sorry, but we couldn't download ${Github_Repository}/${Github_Branch}/${1}${Color_Off}\n"
		exit $exit_status
	fi
	unset $exit_status
fi

# Check if $2 array already exists
[[ ! -z ${!2+x} ]] && printf "${BRed}%s\n%s${Color_Off}\n" \
						"Warning: The variable name '$2' already exists." \
						"We will append the new config settings to the already existing array list."


while read line; do 
    if [[ $line =~ ^"["(.+)"]"$ ]]; then 
        arrname=${BASH_REMATCH[1]}
		if [[ -v $arrname[@] ]]; then
			printf "${BRed}%s\n%s${Color_Off}\n" \
				"Sorry, but we won't override an existing array while reading in a new config file!" \
				"The array '$arrname' has already been declared!"
			exit
		fi
        declare -A $arrname
		eval "${2}+=("$arrname")"
    elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then 
        declare ${arrname}[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
    fi
done < "${Local_Repository}/${1}"
