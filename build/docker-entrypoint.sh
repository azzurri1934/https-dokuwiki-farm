#!/bin/sh -ex

DOCUMENT_ROOT=/var/www/localhost/htdocs
DOKUWIKI_ROOT=$DOCUMENT_ROOT/dokuwiki
FARM_ROOT=$DOCUMENT_ROOT/farm
APACHE_ROOT=/etc/apache2

FARM1=azzu
FARM2=majo
SUB_DOMAIN=wiki.azzu.mydns.jp
CONFIGURED_FLAG=configured

# Configure Dokuwiki, Dokuwiki Farms and Apache.
if [ ! -f $CONFIGURED_FLAG ]; then
 
    # Configure the DokuWiki timezone, e.g. Asia/Tokyo.
    sed -i "s/date_default_timezone_set(@date_default_timezone_get());/date_default_timezone_set('Asia\/Tokyo');/g" $DOKUWIKI_ROOT/inc/init.php

    # Activate DokuWiki Farms.
    cp $DOKUWIKI_ROOT/inc/preload.php.dist $DOKUWIKI_ROOT/inc/preload.php
    sed -i "s/\/\/if(!defined('DOKU_FARMDIR'))/if(!defined('DOKU_FARMDIR'))/g" $DOKUWIKI_ROOT/inc/preload.php
    sed -i "s/\/var\/www\/farm/\/var\/www\/localhost\/htdocs\/farm/g" $DOKUWIKI_ROOT/inc/preload.php
    sed -i "s/\/\/include(fullpath(dirname(__FILE__))/include(fullpath(dirname(__FILE__))/g" $DOKUWIKI_ROOT/inc/preload.php

    # Configure Dokuwiki Farms, e.g. $FARM1(azzu) and $FARM2(majo).
    # Configure the $FARM1(azzu) farm.
    cp -pr $FARM_ROOT/_animal/ $FARM_ROOT/$FARM1/
    sed -i 's/\/\/$conf/$conf/g' $FARM_ROOT/$FARM1/conf/local.protected.php
    sed -i "s/\/farm\/animal/\/$FARM1/g" $FARM_ROOT/$FARM1/conf/local.protected.php

    # Configure the $FARM2(majo) farm.
    cp -pr $FARM_ROOT/_animal/ $FARM_ROOT/$FARM2/
    sed -i 's/\/\/$conf/$conf/g' $FARM_ROOT/$FARM2/conf/local.protected.php
    sed -i "s/\/farm\/animal/\/$FARM2/g" $FARM_ROOT/$FARM2/conf/local.protected.php

    # Configure the $FARM1(azzu) farm alias and the $FARM2(majo) farm alias.
    cat <<EOL >> $APACHE_ROOT/httpd.conf

<IfModule alias_module>
    Alias /$FARM1 $FARM_ROOT/$FARM1
    Alias /$FARM2 $FARM_ROOT/$FARM2
</IfModule>
EOL

    # Configure Apache for DokuWiki Farms.
    sed -i "s/#LoadModule rewrite_module modules/LoadModule rewrite_module modules/g" $APACHE_ROOT/httpd.conf

    cat <<EOL >> $APACHE_ROOT/httpd.conf

<Directory $FARM_ROOT>
    AllowOverride All
    Options +FollowSymLinks

    RewriteEngine On
EOL

    cat <<"EOL" >> $APACHE_ROOT/httpd.conf

    RewriteRule ^/?([^/]+)/(.*)  /dokuwiki/$2?animal=$1 [QSA]
    RewriteRule ^/?([^/]+)$      /dokuwiki/?animal=$1 [QSA]
</Directory>
EOL

    # Configure other Apache settings.
    sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/g" $APACHE_ROOT/httpd.conf

    cat <<EOL >> $APACHE_ROOT/httpd.conf

<VirtualHost *:80>
    ServerName any
    <Location />
        Order Deny,Allow
        Deny from all
    </Location>
</VirtualHost>

<VirtualHost *:80>
    ServerName $SUB_DOMAIN
</VirtualHost>
EOL

    # Turn on the configured flag.
    touch $CONFIGURED_FLAG
fi

# Start Apache.
httpd -D FOREGROUND
