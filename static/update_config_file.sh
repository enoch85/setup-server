#### Write a configuration to a file

###	Input parameter
##	Mandatory
#	$1: 	Array with list of declared arrays that will be written to the config file
#	$2:		File location where the config file will be saved (regardless if there is already one or not!)
## 	Optional
# 	None

### Dependencies (Scripts that need to be in place before using this one here)
#	None

###	Variables that must be set before using this file
#	None

###	Example usage
#	. "${Local_Repository}/source_file.sh" "static/update_config_file.sh" "configXYZ" "configZZZ.cfg"

###	Variables
[[ -z ${BRed+x} ]] && BRed='\e[1;31m'																			# Set default value if variable not set yet
[[ -z ${Color_Off+x} ]] && Color_Off='\e[0m'																	# Set default value if variable not set yet
[[ -z ${Local_Repository+x} ]] && Local_Repository="$HOME/setup-server"											# Set default value if variable not set yet

### Code


# Create new temporary config file (empty it, when it already exists) for the other scripts
# echo "We will now create a new temporary file"
> "${Local_Repository}/${2}.tmp"

# echo "We will now loop over all the elements in your array"
[[ ! -z ${__tmpx+x} ]] && 	printf "${BRed}%s\n${Color_Off}\n" \
									"Warning: The variable '$__tmpx' already exists. We will override it now!"
__tmpx=$1[@]
for idx in "${!__tmpx}"; do
    declare -n temp="$idx"
	printf "[${idx}]\n" >> "${Local_Repository}/${2}.tmp"
	for i in "${!temp[@]}"
	do 
		printf "${i}=${temp[$i]}\n" >> "${Local_Repository}/${2}.tmp"
	done
	printf "\n" >> "${Local_Repository}/${2}.tmp"
done
unset __tmpx

# Replace old config file by new one
# echo "We will now replace your old config file by the new one"
cat "${Local_Repository}/${2}.tmp" > "${Local_Repository}/${2}"


# Delete config.tmp
# echo "We will now delete the temporary config file"
rm "${Local_Repository}/${2}.tmp"