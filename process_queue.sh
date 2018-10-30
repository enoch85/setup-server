while [ -s "${1}" ]; do
	# Read first line
	script=$(head -n 1 ${1})
	# Delete first line
	printf "$(tail -n +2 ${1})" > "${1}"	
	# Execute script
    printf "${BGreen}Execute $script now...${Color_Off}\n" >&2	
	sleep 2
	. "${Local_Repository}/SourceFile.sh" "$script"	
    printf "${BGreen}Done with $script ${Color_Off}\n" >&2
done
