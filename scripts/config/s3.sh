#!/bin/sh

set -e

. /scripts/lib.subr

if [ -z "${OBJECTSTORE_S3_BUCKET}" ]; then
	return 0
fi

info "Configuring s3.config.php ..."

option OBJECTSTORE_S3_BUCKET "${OBJECTSTORE_S3_BUCKET}"

if [ -n "${OBJECTSTORE_S3_SSL}" ]; then
	option OBJECTSTORE_S3_SSL
fi

if [ -n "${OBJECTSTORE_S3_USEPATH_STYLE}" ]; then
	option OBJECTSTORE_S3_USEPATH_STYLE
fi

if [ -n "${OBJECTSTORE_S3_LEGACYPATH}" ]; then
	option OBJECTSTORE_S3_LEGACYPATH
fi

if [ -n "${OBJECTSTORE_S3_AUTOCREATE}" ]; then
	option OBJECTSTORE_S3_AUTOCREATE
fi

if [ -n "${OBJECTSTORE_S3_REGION}" ]; then
	option OBJECTSTORE_S3_REGION "${OBJECTSTORE_S3_REGION}"
fi

if [ -n "${OBJECTSTORE_S3_HOST}" ]; then
	option OBJECTSTORE_S3_HOST "${OBJECTSTORE_S3_HOST}"
fi

if [ -n "${OBJECTSTORE_S3_PORT}" ]; then
	option OBJECTSTORE_S3_PORT "${OBJECTSTORE_S3_PORT}"
fi

if [ -n "${OBJECTSTORE_S3_OBJECT_PREFIX}" ]; then
	option OBJECTSTORE_S3_OBJECT_PREFIX "${OBJECTSTORE_S3_OBJECT_PREFIX}"
fi

if [ -n "${OBJECTSTORE_S3_KEY}" ]; then
	option OBJECTSTORE_S3_KEY "${OBJECTSTORE_S3_KEY}"
fi

if [ -n "${OBJECTSTORE_S3_SECRET}" ]; then
	option OBJECTSTORE_S3_SECRET "${OBJECTSTORE_S3_SECRET}"
fi
