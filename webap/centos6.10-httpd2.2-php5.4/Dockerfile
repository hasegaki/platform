FROM library/centos:6.10
ARG PUID=1000
ARG PGID=1000


# 各種パッケージのインストール
RUN sed -i -e "s/^mirrorlist=http:\/\/mirrorlist.centos.org/#mirrorlist=http:\/\/mirrorlist.centos.org/g" /etc/yum.repos.d/CentOS-Base.repo \
 && sed -i -e "s/^#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g" /etc/yum.repos.d/CentOS-Base.repo
RUN yum update -y \
 && yum install -y http://rpms.famillecollet.com/enterprise/remi-release-6.rpm \
 && yum install -y yum-utils \
 && yum-config-manager --enable remi-php54 \
 && yum clean all && yum makecache \
 && yum reinstall -y glibc-common \
 && yum install -y dos2unix

# 日本語化
ENV LANG ja_JP.UTF-8 
ENV LANGUAGE ja_JP:ja
ENV LANGUAGE ja_JP:ja

RUN echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock  \
 && rm -f /etc/localtime \
 && ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime


# PHPのインストール
RUN yum install -y php-cli php-common php-mbstring php-pear php-curl \
	php-xml php-xmlrpc php-mysqlnd php-pdo

# ユーザ／グループの追加
RUN groupadd -g ${PGID} app \
 && useradd -u ${PUID} -G app appadm

# httpd-2.4のインストール
RUN yum install -y httpd php

# httpdログの出力先変更
RUN ln -s /proc/self/fd/2 /var/log/httpd/access_log \
 && ln -s /proc/self/fd/2 /var/log/httpd/error_log

# httpd.confの変更
RUN echo "Include virtualhost.d/*.conf" >> /etc/httpd/conf/httpd.conf \
 && mkdir /etc/httpd/virtualhost.d \
 && sed -i -E 's/^Listen\s+80$/Listen 0.0.0.0:80/' /etc/httpd/conf/httpd.conf \
 && sed -i -E 's/^User\s+apache$/User appadm/' /etc/httpd/conf/httpd.conf

ADD application.conf.httpd2.2 /etc/httpd/virtualhost.d/application.conf
RUN dos2unix /etc/httpd/virtualhost.d/application.conf \
 && mkdir /var/log/httpd/application \
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
