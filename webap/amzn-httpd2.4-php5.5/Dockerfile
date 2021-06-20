FROM amazonlinux:2018.03
ARG PUID=1000
ARG PGID=1000

ENV TZ=Asia/Tokyo
#ENV LANG=ja_JP.utf8

# インストール済みのパッケージをアップデート＆キャッシュのクリア
RUN yum install -y deltarpm \
 && yum install -y epel-release \
 && yum clean all && yum makecache

# 各種パッケージのインストール
RUN yum install -y yum-utils iproute iputils net-tools tcpdump procps \
	sudo rsync git zip unzip dos2unix \
	cronie cronie-noanacron crontabs \
	openssh-server python38 \
 && pip-3.8 install awscli

# ユーザ／グループの追加
ENV PASSWORD='$6$uDkHrAR3$D1IA0AFwTAcBF6bIGjXERhlwHx2S3hZ0N4855G3wNgSjr9KDd4NLM4iQq2wLt0rdE3tUfw2E2/MFnm8LMLiZ2.'
RUN groupadd -g ${PGID} app \
 && useradd -u ${PUID} -g app -p ${PASSWORD} appadm

# PHP-5.5のインストール
RUN yum install -y php55-cli php55-common php55-mbstring php55-process \
	php55-xml php55-xmlrpc php55-soap php55-json php55-curl php55-gd \
	php55-opcache php55-pdo php55-mysqlnd

# httpd-2.4のインストール
RUN yum install -y httpd24 php55 \
 && usermod -G apache -a appadm

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
