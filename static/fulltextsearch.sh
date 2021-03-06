#!/bin/bash
if [ -z "$MAIN_SETUP" ]
then
	Github_Repository="https://raw.githubusercontent.com/ggeorgg/setup-server"
	Github_Branch="master"
	UseLocalFiles=1	# This variable is for developement purposes, so that we don't have to push changes in a file to github befor testing it.
	Local_Repository="/home/georg/github/ggeorgg/setup-server"
	if [ ! -f "${Local_Repository}/source_file.sh" ] || [ "${UseLocalFiles}" -eq 0 ]; then
	wget -O "${Local_Repository}/source_file.sh" "${Github_Repository}/${Github_Branch}/source_file.sh"
	fi
	# Include functions (download the config file and read it to arrays)
	. "${Local_Repository}/source_file.sh" "lib.sh"

	MAIN_SETUP=0
		
	## Questions
	# . "${Local_Repository}/source_file.sh" "${DIR_Questions}/OfficeQuestions.sh"
	
fi


# Make sure there is an Nextcloud installation
if ! [ "$(occ_command -V)" ]; then
    msg_box "It seems there is no Nextcloud server installed, please check your installation."
    exit 1
fi

# Disable and remove Nextant + Solr
if [ -d "$NC_APPS_PATH"/nextant ]; then
    # Remove Nextant
    msg_box "We will now remove Nextant + Solr and replace it with Full Text Search"
    occ_command app:disable nextant
    rm -rf $NC_APPS_PATH/nextant
    
    # Remove Solr
    service solr stop
    rm -rf /var/solr
    rm -rf /opt/solr*
    rm /etc/init.d/solr
    deluser --remove-home solr
    deluser --group solr
fi

# Reset Full Text Search to be able to index again, and also remove the app to be able to install it again
if [ -d $NC_APPS_PATH/fulltextsearch ]; then
    echo "Removing old version of Full Text Search and resetting the app..."
    occ_command fulltextsearch:reset
    occ_command app:disable fulltextsearch
    rm -rf $NC_APPS_PATH/fulltextsearch
fi
if [ -d $NC_APPS_PATH/fulltextsearch_elasticsearch ]; then
    occ_command app:disable fulltextsearch_elasticsearch
    rm -rf $NC_APPS_PATH/fulltextsearch_elasticsearch
fi
if [ -d $NC_APPS_PATH/files_fulltextsearch ]; then
    occ_command app:disable files_fulltextsearch
    rm -rf $NC_APPS_PATH/files_fulltextsearch
fi

# Check & install docker
apt update -q4 & spinner_loading
install_docker
set_max_count
mkdir -p "$RORDIR"
if docker ps -a | grep "$fts_es_name"; then
    docker stop "$fts_es_name" && docker rm "$fts_es_name" && docker pull "$nc_fts"
else
    docker pull "$nc_fts"
fi

# Create configuration YML 
cat << YML_CREATE > /opt/es/readonlyrest.yml
readonlyrest:
  access_control_rules:
  - name: Accept requests from cloud1 on $INDEX_USER-index
    groups: ["cloud1"]
    indices: ["$INDEX_USER-index"]
    
  users:
  - username: $INDEX_USER
    auth_key: $INDEX_USER:$ROREST
    groups: ["cloud1"]
YML_CREATE

# Set persmissions
chown 1000:1000 -R  $RORDIR
chmod ug+rwx -R  $RORDIR

# Run Elastic Search Docker
docker run -d --restart always \
--name $fts_es_name \
-p 9200:9200 \
-p 9300:9300 \
-v esdata:/usr/share/elasticsearch/data \
-v /opt/es/readonlyrest.yml:/usr/share/elasticsearch/config/readonlyrest.yml \
-e "discovery.type=single-node" \
-i -t $nc_fts

# Wait for bootstraping
docker restart $fts_es_name
countdown "Waiting for docker bootstraping..." "20"
docker logs $fts_es_name

# Get Full Text Search app for nextcloud
install_and_enable_app fulltextsearch
install_and_enable_app fulltextsearch_elasticsearch
install_and_enable_app files_fulltextsearch
chown -R www-data:www-data $NC_APPS_PATH

# Final setup
occ_command fulltextsearch:configure '{"search_platform":"OCA\\FullTextSearch_ElasticSearch\\Platform\\ElasticSearchPlatform"}'
occ_command fulltextsearch_elasticsearch:configure "{\"elastic_host\":\"http://${INDEX_USER}:${ROREST}@localhost:9200\",\"elastic_index\":\"${INDEX_USER}-index\"}"
occ_command files_fulltextsearch:configure "{\"files_pdf\":\"1\",\"files_office\":\"1\"}"
if occ_command fulltextsearch:index < /dev/null; then
	msg_box "Full Text Search was successfully installed!"
fi
