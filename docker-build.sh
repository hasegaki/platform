#!/bin/bash
PROGRAM=`basename $0`
VENDOR=hasegaki
WEBAP=webap
WEBAP_TAGS="amzn2-httpd2.4-php7.2:amzn2:latest \
	alpine3.8-httpd2.4-php7.2:alpine \
	alpine3.8-httpd2.4-php5.6 \
	alpine3.8-httpd2.0-php4.3 \
	amzn-httpd2.4-php7.2:amzn \
	amzn-httpd2.4-php7.1 \
	amzn-httpd2.4-php7.0 \
	amzn-httpd2.4-php5.5 \
	amzn-httpd2.4-php5.4 \
	centos6.10-httpd2.2-php5.4"

BATCH=batch
BATCH_TAGS="amzn2-php7.2:amzn2:latest \
	alpine3.8-php7.2:alpine"

SUBCMD=$1
 
function usage() {
	cat <<EOF
usage: ${PROGRAM} SUBCMD
 SUBCMD:
    build  build image files,
    push   push to docker-hub repository.

EOF
}

function docker_build() {
	_VENDOR=$1
	_SERVER=$2
	_TAG_NAMES=(`echo $3 | sed 's/:/ /g'`)
	_DIR_NAME=${_TAG_NAMES[0]}

	echo docker build -t ${_VENDOR}/${_SERVER}:${_DIR_NAME}
	docker build -t ${_VENDOR}/${_SERVER}:${_DIR_NAME} -f ${_SERVER}/${_DIR_NAME}/Dockerfile ${_SERVER}/${_DIR_NAME}
	_STATUS=$?
	if [ ${_STATUS} -gt 0 ]; then
		exit 1
	fi
}

function docker_tags() {
	_VENDOR=$1
	_SERVER=$2
	_TAG_NAMES=(`echo $3 | sed 's/:/ /g'`)
	_DIR_NAME=${_TAG_NAMES[0]}

	for _TAG_NAME in ${_TAG_NAMES[@]}; do
		if [ ${_TAG_NAME} != ${_DIR_NAME} ]; then
			echo docker tag ${_VENDOR}/${_SERVER}:${_DIR_NAME} ${_VENDOR}/${_SERVER}:${_TAG_NAME}
			docker tag ${_VENDOR}/${_SERVER}:${_DIR_NAME} ${_VENDOR}/${_SERVER}:${_TAG_NAME}
			_STATUS=$?
			if [ ${_STATUS} -gt 0 ]; then
				exit 1
			fi
		fi
	done
}

function docker_push() {
	_VENDOR=$1
	_SERVER=$2
	_TAG_NAMES=(`echo $3 | sed 's/:/ /g'`)

	for _TAG_NAME in ${_TAG_NAMES[@]}; do
		echo push ${_VENDOR}/${_SERVER}:${_TAG_NAME}
		docker push ${_VENDOR}/${_SERVER}:${_TAG_NAME}
		_STATUS=$?
		if [ ${_STATUS} -gt 0 ]; then
			exit 1
		fi
	done
}

for TAG_NAMES in ${WEBAP_TAGS}
do
	case ${SUBCMD} in
	build)
		docker_build ${VENDOR} ${WEBAP} ${TAG_NAMES}
		docker_tags ${VENDOR} ${WEBAP} ${TAG_NAMES}
		;;
	push)
		docker_push ${VENDOR} ${WEBAP} ${TAG_NAMES}
		;;
	*)
		usage
		exit 1
		;;
	esac
done

for TAG_NAMES in ${BATCH_TAGS}
do
	case ${SUBCMD} in
	build)
		docker_build ${VENDOR} ${BATCH} ${TAG_NAMES}
		docker_tags ${VENDOR} ${BATCH} ${TAG_NAMES}
		;;
	push)
		docker_push ${VENDOR} ${BATCH} ${TAG_NAMES}
		;;
	*)
		usage
		exit 1
		;;
	esac
done
