if [ ! -f "$1" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	curl -sL "${Github_Repository}/${Github_Branch}/$1" --create-dirs -o "${Local_Repository}/$1"
fi
source "$1"
