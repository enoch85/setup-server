if [ ! -f "$1" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	echo "We will now get the file:"
	echo "${Github_Repository}/${Github_Branch}/$1"
	echo "The file will be saved as:"
	echo "${Local_Repository}/$1"
	curl -sL "${Github_Repository}/${Github_Branch}/$1" --create-dirs -o "${Local_Repository}/$1"
fi
echo "We following file will be sourced now: ${Local_Repository}/$1"
source "${Local_Repository}/$1"
