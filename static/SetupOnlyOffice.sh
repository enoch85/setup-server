#!/bin/bash
if [ -z "$MAIN_SETUP" ]
then
	Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
	Github_Branch="master"
	UseLocalFiles=1	# This variable is for developement purposes, so that we don't have to push changes in a file to github befor testing it.
	Local_Repository="/home/georg/github/ggeorgg/setup-server"
	if [ ! -f "${Local_Repository}/SourceFile.sh" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	wget -O "${Local_Repository}/SourceFile.sh" "${Github_Repository}/${Github_Branch}/SourceFile.sh"
	fi
	# Include functions (download the config file and read it to arrays)
	. "${Local_Repository}/SourceFile.sh" "lib.sh"

	MAIN_SETUP=0
		
	## Questions
	. "${Local_Repository}/SourceFile.sh" "${DIR_Questions}/OfficeQuestions.sh"
	
fi

# # Check if root
# root_check

# # Nextcloud 13 is required.
# lowest_compatible_nc 13

# Test RAM size (4GB min) + CPUs (min 2)
ram_check 4 OnlyOffice
cpu_check 2 OnlyOffice

# # Check if Collabora is running
# if [ -d "$NCPATH"/apps/richdocuments ]
# then
# msg_box "It seems like Collabora is running.
# You can't run Collabora at the same time as you run OnlyOffice."
    # exit 1
# fi

# # Notification
# msg_box "Before you start, please make sure that port 80+443 is directly forwarded to this machine!"

# # Get the latest packages
# apt update -q4 & spinner_loading

# # Check if Nextcloud is installed
# echo "Checking if Nextcloud is installed..."
# if ! curl -s https://"${NCDOMAIN//\\/}"/status.php | grep -q 'installed":true'
# then
# msg_box "It seems like Nextcloud is not installed or that you don't use https on:
# ${NCDOMAIN//\\/}.
# Please install Nextcloud and make sure your domain is reachable, or activate SSL
# on your domain to be able to run this script.
# If you use the Nextcloud VM you can use the Let's Encrypt script to get SSL and activate your Nextcloud domain.
# When SSL is activated, run these commands from your terminal:
# sudo wget $APP/onlyoffice.sh
# sudo bash onlyoffice.sh"
    # exit 1
# fi


if [ "${Office[SeparateMachine]}" -eq "1" ]; then
	#############################################################################################################
	#############################################################################################################
				
	# Check if $SUBDOMAIN exists and is reachable
	echo
	echo "Checking if $SUBDOMAIN exists and is reachable..."
	if wget -q -T 10 -t 2 --spider "$SUBDOMAIN"; then
	   sleep 0.1
	elif wget -q -T 10 -t 2 --spider --no-check-certificate "https://$SUBDOMAIN"; then
	   sleep 0.1
	elif curl -s -k -m 10 "$SUBDOMAIN"; then
	   sleep 0.1
	elif curl -s -k -m 10 "https://$SUBDOMAIN" -o /dev/null; then
	   sleep 0.1
	else
msg_box "Nope, it's not there. You have to create $SUBDOMAIN and point
it to this server before you can run this script."
	   exit 1
	fi

	# Check open ports with NMAP
	check_open_port 80 "$SUBDOMAIN"
	check_open_port 443 "$SUBDOMAIN"

	# Install Docker
	install_docker

	# Set devicemapper
	check_command cp -v /lib/systemd/system/docker.service /etc/systemd/system/
	sed -i "s|ExecStart=/usr/bin/dockerd -H fd://|ExecStart=/usr/bin/dockerd --storage-driver=devicemapper -H fd://|g" /etc/systemd/system/docker.service
	systemctl daemon-reload
	systemctl restart docker

	# Check if OnlyOffice or Collabora is previously installed
	# If yes, then stop and prune the docker container
	docker_prune_this 'collabora/code' 'onlyoffice/documentserver'

	# Disable Onlyoffice if activated
	if [ -d "$NCPATH"/apps/onlyoffice ]
	then
		occ_command app:disable onlyoffice
		rm -r "$NC_APPS_PATH"/onlyoffice
	fi

	# Install Onlyoffice docker
	docker pull onlyoffice/documentserver:latest
	docker run -i -t -d -p 127.0.0.3:9090:80 --restart always --name onlyoffice onlyoffice/documentserver

	# Install apache2 
	install_if_not apache2

	# Enable Apache2 module's
	a2enmod proxy
	a2enmod proxy_wstunnel
	a2enmod proxy_http
	a2enmod ssl

	# Create Vhost for OnlyOffice online in Apache2
	if [ ! -f "$HTTPS_CONF" ];
	then
		cat << HTTPS_CREATE > "$HTTPS_CONF"
<VirtualHost *:443>
	 ServerName $SUBDOMAIN:443

	SSLEngine on
	ServerSignature On
	SSLHonorCipherOrder on

	SSLCertificateChainFile $CERTFILES/$SUBDOMAIN/chain.pem
	SSLCertificateFile $CERTFILES/$SUBDOMAIN/cert.pem
	SSLCertificateKeyFile $CERTFILES/$SUBDOMAIN/privkey.pem
	SSLOpenSSLConfCmd DHParameters $DHPARAMS
	
	SSLProtocol             all -SSLv2 -SSLv3
	SSLCipherSuite ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS

	LogLevel warn
	CustomLog ${APACHE_LOG_DIR}/access.log combined
	ErrorLog ${APACHE_LOG_DIR}/error.log

	# Just in case - see below
	SSLProxyEngine On
	SSLProxyVerify None
	SSLProxyCheckPeerCN Off
	SSLProxyCheckPeerName Off

	# contra mixed content warnings
	RequestHeader set X-Forwarded-Proto "https"

	# basic proxy settings
	ProxyRequests off

	ProxyPassMatch (.*)(\/websocket)$ "ws://127.0.0.3:9090/$1$2"
	ProxyPass / "http://127.0.0.3:9090/"
	ProxyPassReverse / "http://127.0.0.3:9090/"
		
	<Location />
		ProxyPassReverse /
	</Location>
</VirtualHost>
HTTPS_CREATE

		if [ -f "$HTTPS_CONF" ];
		then
			echo "$HTTPS_CONF was successfully created"
			sleep 1
		else
			echo "Unable to create vhost, exiting..."
			echo "Please report this issue here $ISSUES"
			exit 1
		fi
	fi

	# Install certbot (Let's Encrypt)
	install_certbot

	# Generate certs
	if le_subdomain
	then
		# Generate DHparams chifer
		if [ ! -f "$DHPARAMS" ]
		then
			openssl dhparam -dsaparam -out "$DHPARAMS" 4096
		fi
		printf "%b" "${IGreen}Certs are generated!\n${Color_Off}"
		a2ensite "$SUBDOMAIN.conf"
		restart_webserver
	# Install Onlyoffice App
		cd "$NC_APPS_PATH"
		check_command git clone https://github.com/ONLYOFFICE/onlyoffice-nextcloud.git onlyoffice
	else
		printf "%b" "${IRed}It seems like no certs were generated, please report this issue here: $ISSUES\n${Color_Off}"
		any_key "Press any key to continue... "
		restart_webserver
	fi

	# Enable Onlyoffice
	if [ -d "$NC_APPS_PATH"/onlyoffice ]
	then
	# Enable OnlyOffice
		occ_command app:enable onlyoffice
		occ_command config:app:set onlyoffice DocumentServerUrl --value=https://"$SUBDOMAIN/"
		chown -R www-data:www-data "$NC_APPS_PATH"
		occ_command config:system:set trusted_domains 3 --value="$SUBDOMAIN"
	fi

elif [ "${Office[SeparateMachine]}" -eq "0" ]; then
	#############################################################################################################
	#############################################################################################################

	# Install OnlyOffice on the same machine as nextcloud
	# https://decatec.de/home-server/nextcloud-online-office-mit-onlyoffice/
	
	OfficeCertsDir=/app/onlyoffice/DocumentServer/data/certs
	
	sudo mkdir -p "${OfficeCertsDir}"
	# cd /app/onlyoffice/DocumentServer/data/certs
	# openssl genrsa -out onlyoffice.key 4096 			# Generates onlyoffice.key

	# # Beim Befehl openssl req -new -key onlyoffice.key -out onlyoffice.csr wird man nach dem „Common Name“ 
	# # gefragt (Common Name (e.g. server FQDN or YOUR name)). Hier ist einfach die IP des lokalen Systems 
	# # anzugebnen (z.B. 192.168.178.32). Ebenso kann man ein „challenge password“ angeben. Dieses kann man 
	# # einfach leer lassen (einfach mit Enter bestätigen).
	# #### Not working?
	
	# ADDRESS=$(hostname -I | cut -d ' ' -f 1)	# needs to be set in GlobalParameters?

	# # Are these variable important? (except of \CN, which I know is needed)
	# # /C=NL: 2 letter ISO country code (Netherlands)
	# # /ST=: State, Zuid Holland (South holland)
	# # /L=: Location, city (Rotterdam)
	# # /O=: Organization (Sparkling Network)
	# # /OU=: Organizational Unit, Department (IT Department, Sales)
	# # /CN=: Common Name, for a website certificate this is the FQDN. (ssl.raymii.org)
	# CountryCode="DE"
	# State=""
	# Location=""
	# Organization=""
	# OrganizationUnit=""
	# CommonName="${ADDRESS}"
	# openssl req -new -key onlyoffice.key -out onlyoffice.csr -subj "/C=${CountryCode}/ST=${State}/L=${Location}/O=${Organization}/OU=${OrganizationUnit}/CN=${ADDRESS}"

	# openssl x509 -req -days 3650 -in onlyoffice.csr -signkey onlyoffice.key -out onlyoffice.crt

	# openssl dhparam -out dhparam.pem 2048
	# # Falls es mit 4096 zu lange dauert, kann auch 2048 verwendet werden
	
	ADDRESS=$(hostname -I | cut -d ' ' -f 1)	# needs to be set in GlobalParameters?

	CountryCode="DE"
	State="Bavaria"
	Location="Lichtenfels"
	Organization="Grossmann Technologies"
	OrganizationUnit="IT Department"
	CommonName="${ADDRESS}"
	KeyBitSize=2048

	openssl req -nodes -newkey "rsa:${KeyBitSize}" -keyout "${OfficeCertsDir}/onlyoffice.key" -out "${OfficeCertsDir}onlyoffice.csr" \
	-subj "/C=${CountryCode}/ST=${State}/L=${Location}/O=${Organization}/OU=${OrganizationUnit}/CN=${ADDRESS}"

	openssl x509 -req -days 3650 -in "${OfficeCertsDir}/onlyoffice.csr" -signkey "${OfficeCertsDir}/onlyoffice.key" -out "${OfficeCertsDir}/onlyoffice.crt"

	openssl dhparam -out "${OfficeCertsDir}/dhparam.pem" "${KeyBitSize}"

	chmod 400 "${OfficeCertsDir}/onlyoffice.key"
	chmod 400 "${OfficeCertsDir}/onlyoffice.crt"
	chmod 400 "${OfficeCertsDir}/onlyoffice.csr"
	chmod 400 "${OfficeCertsDir}/dhparam.pem"

	# Generate password for docker connection
	jwt_secret=head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10

	# Install Docker
	install_docker

	docker run --name=onlyoffice -i -t -d -p 4433:443 -e JWT_ENABLED='true' -e JWT_SECRET="$jwt_secret" --restart=always -v /app/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data onlyoffice/documentserver

	occ_command config:system:set onlyoffice verify_peer_off --value=true

	restart_webserver

	# Install Onlyoffice App
	# cd "$NC_APPS_PATH"
	check_command git clone https://github.com/ONLYOFFICE/onlyoffice-nextcloud.git "$NC_APPS_PATH"/onlyoffice

	# Enable Onlyoffice
	if [ -d "$NC_APPS_PATH"/onlyoffice ]
	then
	# Enable OnlyOffice
	occ_command app:enable onlyoffice
	occ_command config:app:set onlyoffice DocumentServerUrl --value="https://${ADDRESS}:4433"
	occ_command config:app:set onlyoffice jwt_secret --value="$jwt_secret"
	occ_command config:app:set onlyoffice sameTab --value=true
	chown -R www-data:www-data "$NC_APPS_PATH"

	fi
fi

# Add prune command
    # {
    # echo "#!/bin/bash"
    # echo "docker system prune -a --force"
    # echo "exit"
    # } > "$SCRIPTS/dockerprune.sh"
    # chmod a+x "$SCRIPTS/dockerprune.sh"
    # crontab -u root -l | { cat; echo "@weekly $SCRIPTS/dockerprune.sh"; } | crontab -u root -
    # echo "Docker automatic prune job added."
    # echo
    # service docker restart
    # docker restart onlyoffice
    # echo "OnlyOffice is now successfully installed."
    # any_key "Press any key to continue... "