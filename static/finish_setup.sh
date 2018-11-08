# Upgrade
apt update -q4 & spinner_loading
apt dist-upgrade -y

# Remove LXD (always shows up as failed during boot)	????
apt purge lxd -y

# Cleanup
apt autoremove -y
apt autoclean

## Do we need this line? Cleanup maybe later?
# find /root "/home/$UNIXUSER" -type f \( -name '*.sh*' -o -name '*.html*' -o -name '*.tar*' -o -name '*.zip*' \) -delete

### Do we always need this?
# Install virtual kernels for Hyper-V, and extra for UTF8 kernel module + Collabora and OnlyOffice
# Kernel 4.15
apt install -y --install-recommends \
linux-virtual \
linux-tools-virtual \
linux-cloud-tools-virtual \
linux-image-virtual \
linux-image-extra-virtual

# Set secure permissions final (./data/.htaccess has wrong permissions otherwise)
. "${Local_Repository}/source_file.sh" "${DIR_STATIC}/setup_secure_permissions_nextcloud.sh"

# Force MOTD to show correct number of updates
sudo /usr/lib/update-notifier/update-motd-updates-available --force

# any_key "First setup block finished, press any key to reboot system and continue afterward..."

# Reboot
# echo "Installation done, system will now reboot..."
reboot
