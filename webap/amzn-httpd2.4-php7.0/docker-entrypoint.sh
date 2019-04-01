#!/bin/bash

if [ ! -f /docker-env ]; then
	cat <<EOF > /docker-env
export TZ=${TZ:=Asia/Tokyo}
export LANG=${LANG:=C}
EOF
fi
. /docker-env

APP_DOCKER_HOST=${APP_DOCKER_HOST:=none}
APP_DOCKER_HOSTIP=${APP_DOCKER_HOSTIP:=auto}
if [ "${APP_DOCKER_HOST}" != 'none' ]; then
	if [ "${APP_DOCKER_HOSTIP}" == 'auto' ]; then
        	APP_DOCKER_HOSTIP=`route -n | gawk '($1 == "0.0.0.0") {print $2}'`
	fi
	cat <<EOF >> /etc/hosts
${APP_DOCKER_HOSTIP} ${APP_DOCKER_HOST}
EOF
fi

exec "$@"
