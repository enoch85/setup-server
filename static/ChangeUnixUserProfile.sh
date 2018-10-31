UNIXUSER="${SudoUser[Username]}"

# Avoid to retype the password after login (will be cleared in cleanup.sh)
cat <<-NoSudoPassword > "/etc/sudoers.d/custom"
${UNIXUSER} ALL = NOPASSWD : ALL
NoSudoPassword

# chmod /etc/sudoers.d/custom 440 ???

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d

# Auto-login the UNIXUSER
cat <<AUTOLOGIN > "/etc/systemd/system/getty@tty1.service.d/override.conf"
[Service]
ExecStart=
ExecStart=-/sbin/agetty --noissue --autologin ${UNIXUSER} %I $TERM
Type=idle
AUTOLOGIN

# Execute the main.sh after login to terminal
cat <<-UNIXUSER-PROFILE > "/home/${UNIXUSER}/.bash_profile"
sudo bash ${Local_Repository}/main.sh
UNIXUSER-PROFILE

# cat <<-UNIXUSER-PROFILE > "/root/.bash_profile"
# sudo apt-get update
# echo "Hier bin ich wieder (root):D"

# UNIXUSER-PROFILE