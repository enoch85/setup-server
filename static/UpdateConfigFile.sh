# Create new temporary config file (empty it, when it already exists) for the other scripts
> "${Local_Repository}/config.cfg.tmp"

# https://stackoverflow.com/a/35543417
for idx in "${arrays[@]}"; do
    declare -n temp="$idx"
	printf "[${idx}]\n" >> "${Local_Repository}/config.cfg.tmp"
	for i in "${!temp[@]}"
	do 
		printf "${i}=${temp[$i]}\n" >> "${Local_Repository}/config.cfg.tmp"
	done
	printf "\n" >> "${Local_Repository}/config.cfg.tmp"
done

# Replace old config file by new one
cat "${Local_Repository}/config.cfg.tmp" > "${Local_Repository}/config.cfg"


# Delete config.tmp
rm "${Local_Repository}/config.cfg.tmp"