FROM library/alpine:3.13
ENV PUID=1000
ENV PGID=1000

RUN apk update \
 && apk add sudo shadow coreutils gzip zip unzip dos2unix \
	zlib zlib-dev libbz2 curl curl-dev tar xz sed coreutils \
	ca-certificates gnupg wget rsync \
	python3 supervisor openssh \
	gettext libmcrypt expat libxml2 postgresql-libs \
 && apk add --update tzdata

RUN groupadd -g ${PGID} app \
 && useradd -u ${PUID} -g app appadm

COPY --from=hasegaki/webap:alpine3.13-httpd2.4-php4.3-build /dist /

WORKDIR /usr/local/openssl
RUN rmdir certs \
 && ln -s /etc/ssl/certs certs

WORKDIR /etc/httpd
ADD php.conf conf/extra
RUN (cd conf \
	&& cp -p httpd.conf httpd.conf.orig \
	&& sed -i -E 's|^Listen\s+(.*)$|Listen 0.0.0.0:80|' httpd.conf \
	&& sed -i -E 's|^User\s+(.*)$|User appadm|' httpd.conf \
	&& sed -i -E 's|^Group\s+(.*)$|Group app|' httpd.conf \
	&& echo "Include conf/extra/php.conf" >> httpd.conf \
 ) \
 && (cd /var/log \
	&& mkdir httpd \
	&& ln -s /dev/fd/2 httpd/access_log \
	&& ln -s /dev/fd/2 httpd/error_log \
 ) \
 && rmdir logs \
 && ln -s /var/log/httpd logs

ADD vhost.d vhost.d
RUN echo "IncludeOptional vhost.d/*.conf" >> conf/httpd.conf \
 && mkdir -p /var/log/httpd/application \
 && ln -s /dev/fd/2 /var/log/httpd/application/access_log \
 && ln -s /dev/fd/2 /var/log/httpd/application/error_log \
 && mkdir -p /var/www/application/public

ADD docker-entrypoint.sh /
RUN dos2unix /docker-entrypoint.sh \
 && chmod +x /docker-entrypoint.sh

ENV LANG=ja_JP.utf8
WORKDIR /
EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/bin/httpd", "-D", "FOREGROUND"]
