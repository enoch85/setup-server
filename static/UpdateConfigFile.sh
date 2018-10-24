# Create new temporary config file (empty it, when it already exists) for the other scripts
# echo "We will now create a new temporary file"
> "${Local_Repository}/${1}.tmp"

# echo "We will now loop over all the elements in your array"
# https://stackoverflow.com/a/35543417
for idx in "${arrays[@]}"; do
    declare -n temp="$idx"
	printf "[${idx}]\n" >> "${Local_Repository}/${1}.tmp"
	for i in "${!temp[@]}"
	do 
		printf "${i}=${temp[$i]}\n" >> "${Local_Repository}/${1}.tmp"
	done
	printf "\n" >> "${Local_Repository}/${1}.tmp"
done

# Replace old config file by new one
# echo "We will now replace your old config file by the new one"
cat "${Local_Repository}/${1}.tmp" > "${Local_Repository}/${1}"


# Delete config.tmp
# echo "We will now delete the temporary config file"
rm "${Local_Repository}/${1}.tmp"