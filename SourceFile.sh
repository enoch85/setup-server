if [ ! -f "$1" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	echo "We will now get the file: ${Github_Repository}/${Github_Branch}/$1 and save it to ${Local_Repository}/$1"
	curl -sL "${Github_Repository}/${Github_Branch}/$1" --create-dirs -o "${Local_Repository}/$1"
fi
echo "We will now source the file: ${Local_Repository}/$1"
source "${Local_Repository}/$1"
