

if [ "${DBMS[PostgreSQL]}" -eq "1" ]; then
	# Install PostgreSQL
	# sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main"
	# wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
	apt update -q4 & spinner_loading
	apt install postgresql-10 -y

	# Create DB
	cd /tmp
sudo -u postgres psql <<END
CREATE USER $NCUSER WITH PASSWORD '$PGDB_PASS';
CREATE DATABASE nextcloud_db WITH OWNER $NCUSER TEMPLATE template0 ENCODING 'UTF8';
END
	service postgresql restart
	
elif [ "${DBMS[MariaDB]}" -eq "1" ]; then
	echo "MariaDB not implemented yet"
	exit
fi

