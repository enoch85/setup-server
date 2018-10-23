if [ ! -f "${Local_Repository}/$1" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	filepath=$(echo $1 | awk '{print $1;}')
	echo "We will now get the file:"
	echo "${Github_Repository}/${Github_Branch}/$filepath"
	echo "The file will be saved as:"
	echo "${Local_Repository}/$filepath"
	curl -sL "${Github_Repository}/${Github_Branch}/$filepath" --create-dirs -o "${Local_Repository}/$filepath"
fi
echo "The following file will be sourced now:"
echo "${Local_Repository}/$filepath"
. "${Local_Repository}/$filepath"
