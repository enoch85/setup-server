#### Curl a file from Github and source it with the given arguments

###	Input parameter
##	Mandatory
#	None
## 	Optional
#	$1-$9: 	Arguments that will be passed to the file that will be sourced 

### Dependencies (Scripts that need to be in place before using this one here)
#	None

### Variables that must be set before sourcing source_file.sh
# 	None

###	Example usage
#	. "${Local_Repository}/source_file.sh" "lib.sh"
#	. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/process_queue.sh" "workflow.txt"

###	Variables
BGreen='\e[1;32m'       # Green
Color_Off='\e[0m'       # Text Reset
BRed='\e[1;31m'         # Red

[[ -z ${UseLocalFiles+x} ]] && UseLocalFiles=1																	# Set default value if variable not set yet
[[ -z ${Local_Repository+x} ]] && Local_Repository="$HOME/setup-server"											# Set default value if variable not set yet
[[ -z ${Github_Repository+x} ]] && Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"	# Set default value if variable not set yet
[[ -z ${Github_Branch+x} ]] && Github_Branch="master"															# Set default value if variable not set yet

### Code

# Download file if ...
# ... file is not on hard drive
# ... UseLocalFiles is set to 0
if [[ ! -f "${Local_Repository}/${1}" || $UseLocalFiles -eq 0 ]]; then
	printf "${BGreen}We will now download ${Github_Repository}/${Github_Branch}/${1}.${Color_Off}\n"
	curl -sLf "${Github_Repository}/${Github_Branch}/${1}" --create-dirs -o "${Local_Repository}/${1}"

	exit_status=$?
	if [[ $exit_status != 0 ]]; then
		printf "${BRed}Sorry, but we couldn't download ${Github_Repository}/${Github_Branch}/${1}${Color_Off}\n"
		if [[ -f "${Local_Repository}/${1}" ]]; then
			printf "${BRed}You are a developer and want to work with the local files? Then for god's sake, set the variable 'UseLocalFiles=1' or upload the file to github!${Color_Off}\n"
		fi
		exit $exit_status
	fi	
	unset $exit_status
fi


# Print which arguments will be passed to the file that is going to be sourced.
printf "${BGreen}$1 will be sourced now.${Color_Off}\n"
if [ $# -gt 1 ]; then
	printf "${BGreen}Arguments:${Color_Off}\n"
	printf "${BGreen} - %s${Color_Off}\n" "${@:2}"
fi

# Source file with the given arguments (file must be there because it has already 
# been on the local repository or it has been downloaded. 
. "${Local_Repository}/${1}" "${@:2}"

