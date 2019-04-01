FROM amazonlinux:2018.03
ARG PUID=1000
ARG PGID=1000

ENV TZ=Asia/Tokyo
#ENV LANG=ja_JP.utf8

# インストール済みのパッケージをアップデート＆キャッシュのクリア
RUN yum install -y deltarpm
#RUN yum update -y
RUN yum install -y epel-release
RUN yum clean all && yum makecache

# 各種パッケージのインストール
RUN yum install -y yum-utils iproute iputils net-tools tcpdump procps
RUN yum install -y sudo rsync git zip unzip dos2unix
RUN yum install -y cronie cronie-noanacron crontabs
RUN yum install -y openssh-server

# PIP、AWS CLIのインストール
RUN curl https://bootstrap.pypa.io/get-pip.py | python
RUN pip install awscli

# ユーザ／グループの追加
RUN groupadd -g ${PGID} app
ENV PASSWORD='$6$uDkHrAR3$D1IA0AFwTAcBF6bIGjXERhlwHx2S3hZ0N4855G3wNgSjr9KDd4NLM4iQq2wLt0rdE3tUfw2E2/MFnm8LMLiZ2.'
RUN useradd -u ${PUID} -g app -p ${PASSWORD} appadm

# PHP-7.0のインストール
RUN yum install -y php70-cli php70-common php70-mbstring php70-process \
	php70-xml php70-xmlrpc php70-soap php70-json php70-curl php70-gd \
	php70-opcache php70-pdo php70-mysqlnd

# composerのインストール
#RUN yum install -y composer
RUN curl -sS https://getcomposer.org/installer | php \
 && mv composer.phar /usr/local/bin/composer \
 && /usr/local/bin/composer diagnose

# Node.js、npmのインストール
#RUN yum install -y npm nodejs
RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
RUN yum install -y nodejs

# httpd-2.4のインストール
RUN yum install -y httpd24 php70
RUN usermod -G apache -a appadm

# httpdログの出力先変更
RUN ln -s /proc/self/fd/2 /var/log/httpd/access_log \
 && ln -s /proc/self/fd/2 /var/log/httpd/error_log

# httpd.confの変更
RUN echo "IncludeOptional virtualhost.d/*.conf" >> /etc/httpd/conf/httpd.conf \
 && sed -i -E 's/^Listen\s+(.*)$/Listen 0.0.0.0:80/' /etc/httpd/conf/httpd.conf \
 && sed -i -E 's/^User\s+(.*)$/User appadm/' /etc/httpd/conf/httpd.conf \ 
 && sed -i -E 's/^Group\s+(.*)$/Group app/' /etc/httpd/conf/httpd.conf \
 && mkdir /etc/httpd/virtualhost.d

# application.conf
ADD application.conf /etc/httpd/virtualhost.d/application.conf
RUN dos2unix /etc/httpd/virtualhost.d/application.conf
RUN mkdir /var/log/httpd/application \
 && ln -s /proc/self/fd/2 /var/log/httpd/application/access_log \
 && ln -s /proc/self/fd/2 /var/log/httpd/application/error_log

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
