# Create new temporary config file (empty it, when it already exists) for the other scripts
> "${CONFIG_FILE_PATH}.tmp"

# https://stackoverflow.com/a/35543417
for idx in "${arrays[@]}"; do
    declare -n temp="$idx"
	printf "[${idx}]\n" >> "${CONFIG_FILE_PATH}.tmp"
	for i in "${!temp[@]}"
	do 
		printf "${i}=${temp[$i]}\n" >> "${CONFIG_FILE_PATH}.tmp"
	done
	printf "\n" >> "${CONFIG_FILE_PATH}.tmp"
done

# Replace old config file by new one
cat "${CONFIG_FILE_PATH}.tmp" > "$CONFIG_FILE_PATH"


# Delete config.tmp
rm "${CONFIG_FILE_PATH}.tmp"