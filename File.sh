if [ ! -f "$1" ] || [ "${UseLocalFiles}" -eq 0 ]
then
	# source <(curl -sL "${Github_Repository}/${Github_Branch}/lib.sh")
	wget -O $1 "${Github_Repository}/${Github_Branch}/$1"
fi
source "$1"
