filepath=$(echo $1 | awk '{print $1;}')
# echo "Input to SourceFile.sh is:"
# echo "$1"
if [ ! -f "${Local_Repository}/${filepath}" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	# echo "We will now get the file:"
	# echo "${Github_Repository}/${Github_Branch}/$filepath"
	# echo "The file will be saved as:"
	# echo "${Local_Repository}/$filepath"
	curl -sL "${Github_Repository}/${Github_Branch}/$filepath" --create-dirs -o "${Local_Repository}/$filepath"
fi
# echo "The following file will be sourced now:"
# echo "${Local_Repository}/$filepath"
# echo "The options are:"
# echo "$2"
. "${Local_Repository}/${filepath}" "$2"
