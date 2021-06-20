FROM amazonlinux:2 as builder
ARG PUID=1000
ARG PGID=1000

ENV TZ=Asia/Tokyo
#ENV LANG=ja_JP.utf8

# インストール済みのパッケージをアップデート＆キャッシュのクリア
RUN yum install -y deltarpm \
 && amazon-linux-extras install -y epel \
 && yum clean all && yum makecache

# 各種パッケージのインストール
RUN yum install -y yum-utils iproute iputils net-tools tcpdump procps \
	sudo rsync git zip unzip dos2unix \
	cronie cronie-noanacron crontabs \
	openssh-server python3 supervisor \
 && pip3 install awscli

# ユーザ／グループの追加
ENV PASSWORD='$6$uDkHrAR3$D1IA0AFwTAcBF6bIGjXERhlwHx2S3hZ0N4855G3wNgSjr9KDd4NLM4iQq2wLt0rdE3tUfw2E2/MFnm8LMLiZ2.'
RUN groupadd -g ${PGID} app \
 && useradd -u ${PUID} -g app -p ${PASSWORD} appadm

# PHP-7.2のインストール
RUN amazon-linux-extras install -y php7.2 \
 && yum install -y php-cli php-common php-mbstring php-process \
	php-xml php-xmlrpc php-soap php-json php-curl php-gd \
	php-opcache php-pdo php-mysqlnd

# composerのインストール
#RUN yum install -y composer
RUN curl -sS https://getcomposer.org/installer | php \
 && mv composer.phar /usr/local/bin/composer \
 && /usr/local/bin/composer diagnose

# Node.js、npmのインストール
RUN yum install -y npm nodejs

# 起動時ディレクトリ
RUN mkdir -p /var/www/application \
 && chown appadm:app /var/www/application
WORKDIR /var/www/application

# エントリポイント作成
ADD ./docker-entrypoint.sh /
RUN dos2unix /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]

# 開放ポート番号
EXPOSE 22
