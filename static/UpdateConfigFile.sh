# Create new temporary config file (empty it, when it already exists) for the other scripts
echo "We will now create a new temporary file"
> "${Local_Repository}/${2}.tmp"

echo "We will now loop over all the elements in your array"
# https://stackoverflow.com/a/35543417
for idx in "${${1}[@]}"; do
    declare -n temp="$idx"
	printf "[${idx}]\n" >> "${Local_Repository}/${2}.tmp"
	for i in "${!temp[@]}"
	do 
		printf "${i}=${temp[$i]}\n" >> "${Local_Repository}/${2}.tmp"
	done
	printf "\n" >> "${Local_Repository}/${2}.tmp"
done

# Replace old config file by new one
cat "${Local_Repository}/${2}.tmp" > "${Local_Repository}/${2}"


# Delete config.tmp
rm "${Local_Repository}/${2}.tmp"