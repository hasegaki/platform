FROM library/alpine:3.13 as INSTALL_PACKAGES
ARG PUID=1000
ARG PGID=1000

ENV TZ=Asia/Tokyo
#ENV LANG=ja_JP.utf8

# 各種パッケージのインストール
RUN apk add sudo shadow bash curl dos2unix rsync git zip unzip \
	python3 py3-pip openssh-server supervisor \
 && pip install awscli

# ユーザ／グループの追加
RUN addgroup -g ${PGID} app \
 && adduser -D -u ${PUID} -G app appadm

# PHP-8.0のインストール
RUN apk add php8 php8-common php8-zip php8-bz2 php8-mbstring php-session \
  php8-curl php8-gd php8-tokenizer php8-phar php8-openssl \
  php8-xml php8-simplexml php8-xmlwriter php8-dom php8-json php8-fileinfo \
  php8-pdo php8-pdo_mysql php8-mysqlnd \
 && ln -s /usr/bin/php8 /usr/bin/php \
 && ln -s /etc/php8 /etc/php

# composerのインストール
RUN curl -sS https://getcomposer.org/installer | php \
 && mv composer.phar /usr/local/bin/composer \
 && /usr/local/bin/composer diagnose

# Node.js、npmのインストール
RUN apk add npm nodejs

# httpd-2.4のインストール
RUN apk add apache2 php8-apache2

# httpdログの出力先変更
RUN ln -s /proc/self/fd/2 /var/www/logs/access.log \
 && ln -s /proc/self/fd/2 /var/www/logs/error.log

# httpd.confの変更
RUN echo "IncludeOptional /etc/apache2/virtualhost.d/*.conf" >> /etc/apache2/httpd.conf \
 && mkdir /etc/apache2/virtualhost.d \
 && sed -i -E 's/^Listen\s+80$/Listen 0.0.0.0:80/' /etc/apache2/httpd.conf \
 && sed -i -E 's/^User\s+apache$/User appadm/' /etc/apache2/httpd.conf \
 && sed -i -E 's/^(#|)(LoadModule\srewrite_module)\s+(.*)$/\2 \3/' /etc/apache2/httpd.conf
ADD application.conf /etc/apache2/virtualhost.d/application.conf
RUN dos2unix /etc/apache2/virtualhost.d/application.conf
RUN mkdir /var/log/apache2/application \
 && ln -s /proc/self/fd/2 /var/log/apache2/application/access.log \
 && ln -s /proc/self/fd/2 /var/log/apache2/application/error.log

# 起動時ディレクトリ
RUN mkdir -p /var/www/application \
 && chown appadm:app /var/www/application
WORKDIR /var/www/application

# エントリポイント作成
ADD ./docker-entrypoint.sh /
RUN dos2unix /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

# 開放ポート番号
EXPOSE 80
