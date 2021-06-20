#!/bin/bash
PROGRAM=`basename $0`
VENDOR=hasegaki
WEBAP=webap
WEBAP_TAGS="
	alpine3.13-httpd2.4-php8.0:php8:alpine:latest
	alpine3.13-httpd2.4-php5.6:php5
	alpine3.13-httpd2.4-php4.3:php4
	alpine3.8-httpd2.4-php7.2:php7
	alpine3.8-httpd2.4-php5.6
	alpine3.8-httpd2.0-php4.3
	amzn2-httpd2.4-php7.3:amzn2
	amzn2-httpd2.4-php7.2
	amzn-httpd2.4-php7.2:amzn
	amzn-httpd2.4-php7.1
	amzn-httpd2.4-php7.0
	amzn-httpd2.4-php5.5
	amzn-httpd2.4-php5.4
	centos6.10-httpd2.2-php5.4
"

BATCH=batch
BATCH_TAGS="
	alpine3.8-php7.2:alpine:latest
	amzn2-php7.3:amzn2
	amzn2-php7.2
"

SUBCMD=$1
 
function usage() {
	cat <<EOF
usage: ${PROGRAM} SUBCMD
 SUBCMD:
    build  build image files,
    tags   set tags
    push   push to docker-hub repository.
    pull   pull from docker-hub repository.
    rmi    clear local image files
EOF
}

function docker_build() {
	_VENDOR=$1
	_SERVER=$2
	_TAG_NAMES=(`echo $3 | sed 's/:/ /g'`)
	_DIR_NAME=${_TAG_NAMES[0]}

	if [ -f ${_SERVER}/${_DIR_NAME}/Dockerfile.build ]; then
		echo docker build -t ${_VENDOR}/${_SERVER}:${_DIR_NAME}-build -f Dockerfile.build
		docker build -t ${_VENDOR}/${_SERVER}:${_DIR_NAME} -f ${_SERVER}/${_DIR_NAME}/Dockerfile.build ${_SERVER}/${_DIR_NAME}
		_STATUS=$?
		if [ ${_STATUS} -gt 0 ]; then
			exit 1
		fi
	fi
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

function docker_pull() {
	_VENDOR=$1
	_SERVER=$2
	_TAG_NAMES=(`echo $3 | sed 's/:/ /g'`)

	for _TAG_NAME in ${_TAG_NAMES[@]}; do
		echo pull ${_VENDOR}/${_SERVER}:${_TAG_NAME}
		docker pull ${_VENDOR}/${_SERVER}:${_TAG_NAME}
		_STATUS=$?
		if [ ${_STATUS} -gt 0 ]; then
			exit 1
		fi
	done
}

function docker_save() {
	_VENDOR=$1
	_SERVER=$2
	_TAG_NAMES=(`echo $3 | sed 's/:/ /g'`)
	_DIR_NAME=${_TAG_NAMES[0]}
	_TAR_FILE=${_SERVER}_${_DIR_NAME}.tar.gz

	echo save ${_VENDOR}/${_SERVER}:${_DIR_NAME}
	docker image save ${_VENDOR}/${_SERVER}:${_DIR_NAME} | gzip > ${_TAR_FILE}
	_STATUS=$?
	if [ ${_STATUS} -gt 0 ]; then
		exit 1
	fi
}

function docker_rmi() {
	_VENDOR=$1
	_SERVER=$2
	_TAG_NAMES=(`echo $3 | sed 's/:/ /g'`)

	for _TAG_NAME in ${_TAG_NAMES[@]}; do
		echo rmi ${_VENDOR}/${_SERVER}:${_TAG_NAME}
		docker rmi ${_VENDOR}/${_SERVER}:${_TAG_NAME}
		_STATUS=$?
#		if [ ${_STATUS} -gt 0 ]; then
#			exit 1
#		fi
	done
}

for TAG_NAMES in ${WEBAP_TAGS}
do
	case ${SUBCMD} in
	build)
		docker_build ${VENDOR} ${WEBAP} ${TAG_NAMES}
		;;
	tags)
		docker_tags ${VENDOR} ${WEBAP} ${TAG_NAMES}
		;;
	push)
		docker_push ${VENDOR} ${WEBAP} ${TAG_NAMES}
		;;
	pull)
		docker_pull ${VENDOR} ${WEBAP} ${TAG_NAMES}
		;;
	save)
		docker_save ${VENDOR} ${WEBAP} ${TAG_NAMES}
		;;
	rmi)
		docker_rmi ${VENDOR} ${WEBAP} ${TAG_NAMES}
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
		;;
	tags)
		docker_tags ${VENDOR} ${BATCH} ${TAG_NAMES}
		;;
	push)
		docker_push ${VENDOR} ${BATCH} ${TAG_NAMES}
		;;
	pull)
		docker_pull ${VENDOR} ${BATCH} ${TAG_NAMES}
		;;
	save)
		docker_save ${VENDOR} ${BATCH} ${TAG_NAMES}
		;;
	rmi)
		docker_rmi ${VENDOR} ${BATCH} ${TAG_NAMES}
		;;
	*)
		usage
		exit 1
		;;
	esac
done
