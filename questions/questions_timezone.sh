sudo dpkg-reconfigure tzdata

temp=$(timedatectl status | grep -m 1 "Time zone:" | awk '{ print $3}')
Timezone[continent]="$(echo ${temp} | cut -d'/' -f1)"
Timezone[city]="$(echo ${temp} | cut -d'/' -f2)"