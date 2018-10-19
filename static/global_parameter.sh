WT_HEIGHT=$(stty size | awk '{print $1;}')
WT_WIDTH=$(stty size | awk '{print $2;}')
ADDRESS=$(hostname -I | cut -d ' ' -f 1)	# needs to be set in GlobalParameters?


CONFIG_FILE_PATH="config.cfg"
DIR_STATIC="static"
DIR_Questions="questions"
# DIR_LETSENCRYPT="./lets-encrypt"
# DIR_APPS="./apps"

# Dirs
SCRIPTS=/var/scripts
NCPATH=/var/www/nextcloud
NC_APPS_PATH=$NCPATH/apps
HTML=/var/www
# NCDATA=/mnt/ncdata
# SNAPDIR=/var/snap/spreedme
GPGDIR=/tmp/gpg
# BACKUP=/mnt/NCBACKUP
RORDIR=/opt/es/


# Repo
GITHUB_REPO="https://raw.githubusercontent.com/nextcloud/vm/master"
STATIC="$GITHUB_REPO/static"
LETS_ENC="$GITHUB_REPO/lets-encrypt"
APP="$GITHUB_REPO/apps"
NCREPO="https://download.nextcloud.com/server/releases"
ISSUES="https://github.com/nextcloud/vm/issues"


# Ubuntu OS
CODENAME=$(lsb_release -c | awk '{print $2}')		# bionic
RELEASE=$(lsb_release -r | awk '{print $2}')		# 18.04
DISTRIBUTORID=$(lsb_release -i | awk '{print $3}')	# Ubuntu

UNIV=$(apt-cache policy | grep http | awk '{print $3}' | grep universe | head -n 1 | cut -d "/" -f 2)


# PHP-FPM
PHP_INI=/etc/php/7.2/fpm/php.ini
PHP_POOL_DIR=/etc/php/7.2/fpm/pool.d

# Database
SHUF=$(shuf -i 25-29 -n 1)
# MARIADB_PASS=$(tr -dc "a-zA-Z0-9@#*=" < /dev/urandom | fold -w "$SHUF" | head -n 1)
# NEWMARIADBPASS=$(tr -dc "a-zA-Z0-9@#*=" < /dev/urandom | fold -w "$SHUF" | head -n 1)
PGDB_PASS=$(tr -dc "a-zA-Z0-9@#*=" < /dev/urandom | fold -w "$SHUF" | head -n 1)
NEWPGPASS=$(tr -dc "a-zA-Z0-9@#*=" < /dev/urandom | fold -w "$SHUF" | head -n 1)

# Apache2
HTTP2_CONF="/etc/apache2/mods-available/http2.conf"
SSL_CONF="/etc/apache2/sites-available/nextcloud_ssl_domain_self_signed.conf"
HTTP_CONF="/etc/apache2/sites-available/nextcloud_http_domain_self_signed.conf"

# Nextcloud
[ ! -z "$NC_UPDATE" ] && CURRENTVERSION=$(sudo -u www-data php $NCPATH/occ status | grep "versionstring" | awk '{print $3}')
NCVERSION=$(curl -s -m 900 $NCREPO/ | sed --silent 's/.*href="nextcloud-\([^"]\+\).zip.asc".*/\1/p' | sort --version-sort | tail -1)
STABLEVERSION="nextcloud-$NCVERSION"
NCMAJOR="${NCVERSION%%.*}"
NCBAD=$((NCMAJOR-2))
NCPASS=nextcloud

# Keys
OpenPGP_fingerprint='28806A878AE423A28372792ED75899B9A724937A'


# # Adminer
# ADMINERDIR=/usr/share/adminer
# ADMINER_CONF=/etc/apache2/conf-available/adminer.conf
# Redis
REDIS_CONF=/etc/redis/redis.conf
REDIS_SOCK=/var/run/redis/redis-server.sock
RSHUF=$(shuf -i 30-35 -n 1)
REDIS_PASS=$(tr -dc "a-zA-Z0-9@#*=" < /dev/urandom | fold -w "$RSHUF" | head -n 1)

# Full text Search
[ ! -z "$ES_INSTALL" ] && INDEX_USER=$(tr -dc '[:lower:]' < /dev/urandom | fold -w "$SHUF" | head -n 1)
[ ! -z "$ES_INSTALL" ] && ROREST=$(tr -dc "A-Za-z0-9" < /dev/urandom | fold -w "$SHUF" | head -n 1)
[ ! -z "$ES_INSTALL" ] && DOCKER_INS=$(dpkg -l | grep ^ii | awk '{print $2}' | grep docker)
[ ! -z "$ES_INSTALL" ] && nc_fts="ark74/nc_fts"
[ ! -z "$ES_INSTALL" ] && fts_es_name="fts_esror"

# Letsencrypt
LETSENCRYPTPATH="/etc/letsencrypt"
CERTFILES="$LETSENCRYPTPATH/live"
# DHPARAMS="$CERTFILES/$SUBDOMAIN/dhparam.pem"
