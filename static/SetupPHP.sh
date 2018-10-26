# Install PHP 7.2
apt update -q4 & spinner_loading
check_command apt install -y \
    php7.2-fpm \
    php7.2-intl \
    php7.2-ldap \
    php7.2-imap \
    php7.2-gd \
    php7.2-pgsql \
    php7.2-curl \
    php7.2-xml \
    php7.2-zip \
    php7.2-mbstring \
    php7.2-soap \
    php7.2-smbclient \
    php7.2-imagick \
    php7.2-json \
    php7.2-gmp \
    php7.2-bz2 \
    php-pear \
    libmagickcore-6.q16-3-extra
    
# Enable php-fpm
a2enconf php7.2-fpm
