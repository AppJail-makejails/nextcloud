#!/bin/sh

set -e

. /scripts/lib.subr

if [ -n "${OVERWRITEHOST}" ]; then
	option OVERWRITEHOST "${OVERWRITEHOST}"
fi

if [ -n "${OVERWRITEPROTOCOL}" ]; then
	option OVERWRITEPROTOCOL "${OVERWRITEPROTOCOL}"
fi

if [ -n "${OVERWRITECLIURL}" ]; then
	option OVERWRITECLIURL "${OVERWRITECLIURL}"
fi

if [ -n "${OVERWRITEWEBROOT}" ]; then
	option OVERWRITEWEBROOT "${OVERWRITEWEBROOT}"
fi

if [ -n "${OVERWRITECONDADDR}" ]; then
	option OVERWRITECONDADDR "${OVERWRITECONDADDR}"
fi

if [ -n "${TRUSTED_PROXIES}" ]; then
	option TRUSTED_PROXIES "${TRUSTED_PROXIES}"
fi
