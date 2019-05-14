FROM alpine:3.9

COPY ./docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

VOLUME ["/etc/apache2", "/var/www/localhost/htdocs"]

ENTRYPOINT ["/docker-entrypoint.sh"]
