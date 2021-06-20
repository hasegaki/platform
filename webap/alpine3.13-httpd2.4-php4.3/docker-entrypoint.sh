#!/bin/sh
WORKDIR=$(pwd)
if [ -f /docker-env ]; then
	. /docker-env
fi

if [ -d /docker-init.d ]; then
	cd /docker-init.d
	for sh in *.sh; do
		if [ $sh == '*.sh' ]; then
			true # NOP
		elif [ -x $sh ]; then
			./$sh "$@"
			STATUS=$?
			if [ $STATUS -gt 0 ]; then
				exit $STATUS
			fi
		else
			echo "$sh: not executable file. skipped."
		fi
	done
fi

cd ${WORKDIR}
exec "$@"
