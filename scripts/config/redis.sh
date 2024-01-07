#!/bin/sh

set -e

. /scripts/lib.subr

if [ -z "${REDIS_HOST}" ]; then
	return 0
fi

info "Configuring redis.config.php ..."

option REDIS_HOST "${REDIS_HOST}"

if [ -n "${REDIS_HOST_PASSWORD}" ]; then
	option REDIS_HOST_PASSWORD "${REDIS_HOST_PASSWORD}"
fi

if [ -n "${REDIS_HOST_PORT}" ]; then
	option REDIS_HOST_PORT "${REDIS_HOST_PORT}"
fi

info "Configuring Redis as session handler ..."

{
	echo 'session.save_handler = redis'

	# check if redis host is an unix socket path
	if [ "`echo "$REDIS_HOST" | cut -c1-1`" = "/" ]; then
		if [ -n "${REDIS_HOST_PASSWORD}" ]; then
			echo "session.save_path = \"unix://${REDIS_HOST}?auth=${REDIS_HOST_PASSWORD}\""
		else
			echo "session.save_path = \"unix://${REDIS_HOST}\""
		fi
	# check if redis password has been set
	elif [ -n "${REDIS_HOST_PASSWORD}" ]; then
		echo "session.save_path = \"tcp://${REDIS_HOST}:${REDIS_HOST_PORT:=6379}?auth=${REDIS_HOST_PASSWORD}\""
	else
		echo "session.save_path = \"tcp://${REDIS_HOST}:${REDIS_HOST_PORT:=6379}\""
	fi
	echo "redis.session.locking_enabled = 1"
	echo "redis.session.lock_retries = -1"
	# redis.session.lock_wait_time is specified in microseconds.
	# Wait 10ms before retrying the lock rather than the default 2ms.
	echo "redis.session.lock_wait_time = 10000"
} > "/usr/local/etc/php/redis-session.ini"
