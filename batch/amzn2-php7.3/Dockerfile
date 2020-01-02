FROM amazonlinux:2
ARG PUID=1000
ARG PGID=1000

ENV TZ=Asia/Tokyo
#ENV LANG=ja_JP.utf8

# インストール済みのパッケージをアップデート＆キャッシュのクリア
RUN yum install -y deltarpm
#RUN yum update -y
RUN amazon-linux-extras install -y epel
RUN yum clean all && yum makecache

# 各種パッケージのインストール
RUN yum install -y yum-utils iproute iputils net-tools tcpdump procps
RUN yum install -y sudo rsync git zip unzip dos2unix
RUN yum install -y cronie cronie-noanacron crontabs
RUN yum install -y openssh-server python3 supervisor

# PIP、AWS CLIのインストール
RUN curl https://bootstrap.pypa.io/get-pip.py | python3
RUN pip install awscli

# ユーザ／グループの追加
RUN groupadd -g ${PGID} app
RUN useradd -u ${PUID} -g app appadm

# PHP-7.3のインストール
RUN amazon-linux-extras install -y php7.3
RUN yum install -y php-cli php-common php-mbstring php-process \
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
