FROM library/alpine:3.8

ARG PUID=1000
ARG PGID=1000

RUN apk update \
 && apk add sudo shadow coreutils gzip zip unzip dos2unix \
	zlib zlib-dev curl curl-dev tar xz sed coreutils \
	ca-certificates gnupg wget rsync \
	python3 supervisor openssh openssl \
 && apk add --update tzdata

RUN groupadd -g ${PGID} app \
 && useradd -u ${PUID} -g app appadm

# PHP 5.6のインストール
RUN apk add php5-cli php5-common php5-zip php5-bz2 \
	php5-curl php5-gd php5-phar php5-openssl \
	php5-xml php5-xmlreader php5-dom php5-json \
	php5-pdo php5-pdo_pgsql php5-pgsql

# Apache httpd 2.4のインストール
RUN apk add apache2 php5-apache2

WORKDIR /etc/apache2
RUN cp -p httpd.conf httpd.conf.orig \
 && sed -i -E 's|^Listen\s+(.*)$|Listen 0.0.0.0:80|' httpd.conf \
 && sed -i -E 's|^User\s+(.*)$|User appadm|' httpd.conf \
 && sed -i -E 's|^Group\s+(.*)$|Group app|' httpd.conf \
 && sed -i -E 's|^CustomLog\s+(.*)\s+(.*)$|CustomLog /var/log/httpd/access.log combined|' httpd.conf \
 && sed -i -E 's|^ErrorLog\s+(.*)$|ErrorLog /var/log/httpd/error.log|' httpd.conf
RUN mkdir /var/log/httpd \
 && ln -s /dev/fd/2 /var/log/httpd/access.log \
 && ln -s /dev/fd/2 /var/log/httpd/error.log
RUN mkdir /run/apache2

RUN mkdir virtualhost.d \
 && echo "IncludeOptional /etc/apache2/virtualhost.d/*.conf" >> httpd.conf
RUN mkdir /var/log/httpd/application \
 && ln -s /dev/fd/2 /var/log/httpd/application/access.log \
 && ln -s /dev/fd/2 /var/log/httpd/application/error.log

ADD application.conf virtualhost.d/application.conf

ADD docker-entrypoint.sh /
RUN dos2unix /docker-entrypoint.sh \
 && chmod +x /docker-entrypoint.sh

WORKDIR /var/www/application
EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

RUN ln -s /usr/bin/php5 /usr/bin/php
