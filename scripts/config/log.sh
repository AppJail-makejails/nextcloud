#!/bin/sh

set -e

. /scripts/lib.subr

if [ -z "${LOGTIMEZONE}" ]; then
	return 0
fi

info "Configuring log.config.php ..."

option LOGTIMEZONE "${LOGTIMEZONE}"
