#### Read a given file line by line and source a file 
#### for each line in this file

###	Input parameter
##	Mandatory
#	$1: 	File location of queue
## 	Optional
# 	$2-$9: 	Arguments that will be passed to the file that will be sourced

### Dependencies (Scripts that need to be in place before using this one here)
#	"${Local_Repository}/source_file.sh"

###	Variables that must be set before using this file
#	None

###	Example usage
#	. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/process_queue.sh" "workflow.txt"

###	Variables
[[ -z ${BRed+x} ]] && BRed='\e[1;31m'																			# Set default value if variable not set yet
[[ -z ${Color_Off+x} ]] && Color_Off='\e[0m'																	# Set default value if variable not set yet
[[ -z ${Local_Repository+x} ]] && Local_Repository="$HOME/setup-server"											# Set default value if variable not set yet

### Code

if [[ -f "${Local_Repository}/${1}" ]]; then
	while [ -s "${1}" ]; do
		# Read first line
		script=$(head -n 1 ${1})
		
		# Delete first line
		printf "$(tail -n +2 ${1})" > "${1}"
		
		# Source script if source_file.sh exists (Maybe donwnload the source_file.sh if it does not exist?)
		if [[ -f "${Local_Repository}/source_file.sh" ]]; then
			. "${Local_Repository}/source_file.sh" "$script"	"${@:2}"
		else
			printf "${BRed}Sorry, but ${Local_Repository}/source_file.sh does not exist!${Color_Off}\n"
			exit
		fi
	done
else
	printf "${BRed}Sorry, but ${Local_Repository}/${1} does not exist!${Color_Off}\n"
	exit
fi
