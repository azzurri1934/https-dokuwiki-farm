#!/bin/sh -ex

DOCUMENT_ROOT=/var/www/localhost/htdocs
DOKUWIKI_ROOT=$DOCUMENT_ROOT/dokuwiki
FARM_ROOT=$DOCUMENT_ROOT/farm
APACHE_ROOT=/etc/apache2

DOKUWIKI_TAR_FILE=release_stable_2018-04-22b.tar.gz
DOKUWIKI_FARM_ANIMAL_ZIP_FILE=dokuwiki_farm_animal.zip

SUB_DOMAIN=wiki.azzu.mydns.jp

if [ -z "$(ls $DOCUMENT_ROOT)" ]; then
  apk update
  apk add --no-cache apache2 php7-apache2 php7-mbstring php7-session php7-json php7-xml php7-openssl openrc
  
  mkdir $DOKUWIKI_ROOT
  wget https://github.com/splitbrain/dokuwiki/archive/$DOKUWIKI_TAR_FILE
  tar -zxvf $DOKUWIKI_TAR_FILE -C $DOKUWIKI_ROOT --strip-components 1
  rm $DOKUWIKI_TAR_FILE
  
  mkdir $FARM_ROOT
  wget https://www.dokuwiki.org/_media/$DOKUWIKI_FARM_ANIMAL_ZIP_FILE
  unzip $DOKUWIKI_FARM_ANIMAL_ZIP_FILE -d $FARM_ROOT
  rm $DOKUWIKI_FARM_ANIMAL_ZIP_FILE

  cp $DOKUWIKI_ROOT/inc/preload.php.dist $DOKUWIKI_ROOT/inc/preload.php
  sed -i "s/\/\/if(!defined('DOKU_FARMDIR'))/if(!defined('DOKU_FARMDIR'))/g" $DOKUWIKI_ROOT/inc/preload.php
  sed -i "s/\/var\/www\/farm/\/var\/www\/localhost\/htdocs\/farm/g" $DOKUWIKI_ROOT/inc/preload.php
  sed -i "s/\/\/include(fullpath(dirname(__FILE__))/include(fullpath(dirname(__FILE__))/g" $DOKUWIKI_ROOT/inc/preload.php

  sed -i "s/date_default_timezone_set(@date_default_timezone_get());/date_default_timezone_set('Asia\/Tokyo');/g" $DOKUWIKI_ROOT/inc/init.php

  sed -i "s/#LoadModule rewrite_module modules/LoadModule rewrite_module modules/g" $APACHE_ROOT/httpd.conf
  sed -i "s/Options Indexes FollowSymLinks/Options FollowSymLinks/g" $APACHE_ROOT/httpd.conf

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

  chown -R apache:apache $DOCUMENT_ROOT
fi

httpd -D FOREGROUND
