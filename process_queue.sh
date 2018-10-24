while [ -s "${1}" ]; do
	# Read first line
	script=$(head -n 1 ${1})
	# Delete first line
	printf "$(tail -n +2 ${1})" > "${1}"	
	# Execute script
	. "${Local_Repository}/SourceFile.sh" "$script"	
done
