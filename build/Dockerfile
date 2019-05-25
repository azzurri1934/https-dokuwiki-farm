FROM alpine:3.9

ARG DOCUMENT_ROOT=/var/www/localhost/htdocs
ARG DOKUWIKI_ROOT=$DOCUMENT_ROOT/dokuwiki
ARG FARM_ROOT=$DOCUMENT_ROOT/farm
ARG DOKUWIKI_TAR_FILE=release_stable_2018-04-22b.tar.gz
ARG DOKUWIKI_FARM_ANIMAL_ZIP_FILE=dokuwiki_farm_animal.zip

COPY ./docker-entrypoint.sh /

RUN apk update && apk add --no-cache \
        apache2 \
        openrc \
        php7-apache2 \
        php7-json \
        php7-mbstring \
        php7-openssl \
        php7-session \
        php7-xml \
    && mkdir $DOKUWIKI_ROOT \
    && wget https://github.com/splitbrain/dokuwiki/archive/$DOKUWIKI_TAR_FILE \
    && tar -zxvf $DOKUWIKI_TAR_FILE -C $DOKUWIKI_ROOT --strip-components 1 \
    && rm $DOKUWIKI_TAR_FILE \
    && mkdir $FARM_ROOT \
    && wget https://www.dokuwiki.org/_media/$DOKUWIKI_FARM_ANIMAL_ZIP_FILE \
    && unzip $DOKUWIKI_FARM_ANIMAL_ZIP_FILE -d $FARM_ROOT \
    && rm $DOKUWIKI_FARM_ANIMAL_ZIP_FILE \
    && chown -R apache:apache $DOCUMENT_ROOT \
    && chmod +x /docker-entrypoint.sh

EXPOSE 80

VOLUME ["/etc/apache2", "/var/www/localhost/htdocs"]

ENTRYPOINT ["/docker-entrypoint.sh"]
