#!/bin/sh

set -e

. /scripts/lib.subr

if [ -z "${OBJECTSTORE_SWIFT_URL}" ]; then
	return 0
fi

info "Configuring swift.config.php ..."

option OBJECTSTORE_SWIFT_URL "${OBJECTSTORE_SWIFT_URL}"

if [ -n "${OBJECTSTORE_SWIFT_AUTOCREATE}" ]; then
	option OBJECTSTORE_SWIFT_AUTOCREATE
fi

if [ -n "${OBJECTSTORE_SWIFT_USER_NAME}" ]; then
	option OBJECTSTORE_SWIFT_USER_NAME "${OBJECTSTORE_SWIFT_USER_NAME}"
fi

if [ -n "${OBJECTSTORE_SWIFT_USER_PASSWORD}" ]; then
	option OBJECTSTORE_SWIFT_USER_PASSWORD "${OBJECTSTORE_SWIFT_USER_PASSWORD}"
fi

if [ -n "${OBJECTSTORE_SWIFT_USER_DOMAIN}" ]; then
	option OBJECTSTORE_SWIFT_USER_DOMAIN "${OBJECTSTORE_SWIFT_USER_DOMAIN}"
fi

if [ -n "${OBJECTSTORE_SWIFT_PROJECT_NAME}" ]; then
	option OBJECTSTORE_SWIFT_PROJECT_NAME "${OBJECTSTORE_SWIFT_PROJECT_NAME}"
fi

if [ -n "${OBJECTSTORE_SWIFT_PROJECT_DOMAIN}" ]; then
	option OBJECTSTORE_SWIFT_PROJECT_DOMAIN "${OBJECTSTORE_SWIFT_PROJECT_DOMAIN}"
fi

if [ -n "${OBJECTSTORE_SWIFT_SERVICE_NAME}" ]; then
	option OBJECTSTORE_SWIFT_SERVICE_NAME "${OBJECTSTORE_SWIFT_SERVICE_NAME}"
fi

if [ -n "${OBJECTSTORE_SWIFT_REGION}" ]; then
	option OBJECTSTORE_SWIFT_REGION "${OBJECTSTORE_SWIFT_REGION}"
fi

if [ -n "${OBJECTSTORE_SWIFT_CONTAINER_NAME}" ]; then
	option OBJECTSTORE_SWIFT_CONTAINER_NAME "${OBJECTSTORE_SWIFT_CONTAINER_NAME}"
fi
