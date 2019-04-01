FROM library/alpine:3.8
ARG PUID=1000
ARG PGID=1000

ENV TZ=Asia/Tokyo
#ENV LANG=ja_JP.utf8

# 各種パッケージのインストール
RUN apk add sudo shadow bash curl dos2unix rsync git zip unzip
RUN apk add python3 openssh-server supervisor

# PIP、AWS CLIのインストール
RUN curl https://bootstrap.pypa.io/get-pip.py | python3
RUN pip install awscli

# ユーザ／グループの追加
RUN addgroup -g ${PGID} app
RUN adduser -D -u ${PUID} -G app appadm

# PHP-7.2のインストール
RUN apk add php7 php7-common php7-zip php7-bz2 php7-mbstring php-session \
  php7-curl php7-gd php7-tokenizer php7-phar php7-openssl \
  php7-xml php7-simplexml php7-xmlwriter php7-dom php7-json php7-fileinfo \
  php7-pdo php7-pdo_mysql php7-mysqlnd

# composerのインストール
RUN curl -sS https://getcomposer.org/installer | php \
 && mv composer.phar /usr/local/bin/composer \
 && /usr/local/bin/composer diagnose

# Node.js、npmのインストール
RUN apk add npm nodejs

# httpd-2.4のインストール
RUN apk add apache2 php7-apache2

# httpdログの出力先変更
RUN ln -s /proc/self/fd/2 /var/www/logs/access.log \
 && ln -s /proc/self/fd/2 /var/www/logs/error.log
RUN mkdir /var/run/apache2

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
