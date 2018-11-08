# To be able to use snakeoil certs
install_if_not ssl-cert



NCDATA="${DataDisk[DataDirectory]}"

# Generate $HTTP_CONF
if [ ! -f $HTTP_CONF ]
then
    touch "$HTTP_CONF"
    cat << HTTP_CREATE > "$HTTP_CONF"
<VirtualHost *:80>

### YOUR SERVER ADDRESS ###
#    ServerAdmin admin@example.com
#    ServerName example.com
#    ServerAlias subdomain.example.com

### SETTINGS ###
    <FilesMatch "\.php$">
        SetHandler "proxy:unix:/run/php/php7.2-fpm.nextcloud.sock|fcgi://localhost"
    </FilesMatch>

    DocumentRoot $NCPATH

    <Directory $NCPATH>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    Satisfy Any
    </Directory>

    <IfModule mod_dav.c>
    Dav off
    </IfModule>

    <Directory "$NCDATA">
    # just in case if .htaccess gets disabled
    Require all denied
    </Directory>
    
    # The following lines prevent .htaccess and .htpasswd files from being
    # viewed by Web clients.
    <Files ".ht*">
    Require all denied
    </Files>
    
    # Disable HTTP TRACE method.
    TraceEnable off

    # Disable HTTP TRACK method.
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} ^TRACK
    RewriteRule .* - [R=405,L]

    SetEnv HOME $NCPATH
    SetEnv HTTP_HOME $NCPATH

</VirtualHost>
HTTP_CREATE
    echo "$HTTP_CONF was successfully created"
fi

# Generate $SSL_CONF
if [ ! -f $SSL_CONF ]
then
    touch "$SSL_CONF"
    cat << SSL_CREATE > "$SSL_CONF"
<VirtualHost *:443>
    Header add Strict-Transport-Security: "max-age=15768000;includeSubdomains"
    Header always set Referrer-Policy "strict-origin"
    SSLEngine on

### YOUR SERVER ADDRESS ###
#    ServerAdmin admin@example.com
#    ServerName example.com
#    ServerAlias subdomain.example.com

### SETTINGS ###
    <FilesMatch "\.php$">
        SetHandler "proxy:unix:/run/php/php7.2-fpm.nextcloud.sock|fcgi://localhost"
    </FilesMatch>

    DocumentRoot $NCPATH

    <Directory $NCPATH>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    Satisfy Any
    </Directory>

    <IfModule mod_dav.c>
    Dav off
    </IfModule>

    <Directory "$NCDATA">
    # just in case if .htaccess gets disabled
    Require all denied
    </Directory>
    
    # The following lines prevent .htaccess and .htpasswd files from being
    # viewed by Web clients.
    <Files ".ht*">
    Require all denied
    </Files>
    
    # Disable HTTP TRACE method.
    TraceEnable off

    # Disable HTTP TRACK method.
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} ^TRACK
    RewriteRule .* - [R=405,L]

    SetEnv HOME $NCPATH
    SetEnv HTTP_HOME $NCPATH

### LOCATION OF CERT FILES ###
    SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
</VirtualHost>
SSL_CREATE
    echo "$SSL_CONF was successfully created"
fi

# Enable new config
a2ensite nextcloud_ssl_domain_self_signed.conf
a2ensite nextcloud_http_domain_self_signed.conf
a2dissite default-ssl
restart_webserver
