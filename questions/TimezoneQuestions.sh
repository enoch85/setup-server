dpkg-reconfigure tzdata

temp=$(timedatectl status | grep -m 1 "Time zone:" | awk '{ print $3}')
Timezone[Continent]="$(echo ${temp} | cut -d'/' -f1)"
Timezone[City]="$(echo ${temp} | cut -d'/' -f2)"