FROM library/alpine:3.8

ENV PUID=1000
ENV PGID=1000

RUN apk update
RUN apk add sudo shadow coreutils gzip zip unzip dos2unix \
	zlib zlib-dev curl curl-dev tar xz sed coreutils \
	ca-certificates gnupg wget rsync
RUN apk add python3 supervisor openssh openssl
RUN apk add --update tzdata

RUN groupadd -g ${PGID} app
RUN useradd -u ${PUID} -g app appadm

RUN apk add autoconf dpkg-dev dpkg file g++ gcc make pkgconf re2c \
	bison flex gettext gettext-dev libmcrypt libmcrypt-dev \
	postgresql-libs postgresql-dev

ADD httpd-2.0.65.tar.gz /usr/local/src
WORKDIR /usr/local/src/httpd-2.0.65
RUN ./configure \
	--with-z \
	--enable-so \
	--enable-cgi \
	--enable-info \
	--enable-rewrite \
	--enable-speling \
	--enable-usertrack \
	--enable-deflate \
	--enable-mime-magic \
	--enable-proxy \
	--prefix=/usr/local/apache2
RUN make all install \
 && rm -rf /usr/local/src/httpd-2.0.65

ADD php-4.3.11.tar.gz /usr/local/src
WORKDIR /usr/local/src/php-4.3.11
RUN ./configure \
	--enable-mbstring \
	--without-imap \
	--without-mysql \
	--with-gettext \
	--with-xml \
	--with-mcrypt \
	--with-zlib \
	--with-pgsql \
	--with-mime-magic \
	--with-apxs2=/usr/local/apache2/bin/apxs \
	--with-config-file-path="/etc/php4" \
	--with-config-file-scan-dir="/etc/php4/conf.d" \
	--prefix=/usr/local/php4
RUN make all install \
 && rm -rf /usr/local/src/php-4.3.11

WORKDIR /usr/local/apache2/conf
RUN cp -p httpd.conf httpd.conf.orig
RUN sed -i -E 's|^Listen\s+(.*)$|Listen 0.0.0.0:80|' httpd.conf
RUN sed -i -E 's|^User\s+(.*)$|User appadm|' httpd.conf
RUN sed -i -E 's|^Group\s+(.*)$|Group app|' httpd.conf
RUN sed -i -E 's|^CustomLog\s+(.*)\s+(.*)$|CustomLog /var/log/httpd/access.log combined|' httpd.conf
RUN sed -i -E 's|^ErrorLog\s+(.*)$|ErrorLog /var/log/httpd/error.log|' httpd.conf
RUN mkdir /var/log/httpd \
 && ln -s /dev/fd/2 /var/log/httpd/access.log \
 && ln -s /dev/fd/2 /var/log/httpd/error.log

WORKDIR /usr/local/apache2
RUN mkdir conf.d \
 && echo "Include conf.d/*.conf" >> conf/httpd.conf
ADD mod_php4.conf conf.d

RUN mkdir virtualhost.d \
 && echo "Include virtualhost.d/*.conf" >> conf/httpd.conf
RUN mkdir /var/log/httpd/application \
 && ln -s /dev/fd/2 /var/log/httpd/application/access.log \
 && ln -s /dev/fd/2 /var/log/httpd/application/error.log

ADD application.conf virtualhost.d/application.conf

ADD docker-entrypoint.sh /
RUN dos2unix /docker-entrypoint.sh \
 && chmod +x /docker-entrypoint.sh

ENV PATH=$PATH:/usr/local/php4/bin:/usr/local/apache2/bin
ENV LANG=ja_JP.utf8
WORKDIR /var/www/application
EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/apache2/bin/httpd", "-D", "FOREGROUND"]
