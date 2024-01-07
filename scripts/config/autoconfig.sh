#!/bin/sh

set -e

. /scripts/lib.subr

info "Configuring autoconfig.php ..."

autoconfig_enabled=false

if [ -n "${SQLITE_DATABASE}" ]; then
	info "Configuring SQLite as database backend ..."
	option SQLITE_DATABASE "${SQLITE_DATABASE}"
	autoconfig_enabled=true
elif [ -n "${MYSQL_DATABASE}" -a -n "${MYSQL_USER}" -a -n "${MYSQL_PASSWORD}" -a -n "${MYSQL_HOST}" ]; then
	info "Configuring MySQL/MariaDB as database backend ..."
	option MYSQL_DATABASE "${MYSQL_DATABASE}"
	option MYSQL_USER "${MYSQL_USER}"
	option MYSQL_PASSWORD "${MYSQL_PASSWORD}"
	option MYSQL_HOST "${MYSQL_HOST}"
	autoconfig_enabled=true
elif [ -n "${POSTGRES_DB}" -a -n "${POSTGRES_USER}" -a -n "${POSTGRES_PASSWORD}" -a -n "${POSTGRES_HOST}" ]; then
	info "Configuring PostgreSQL as database backend ..."
	option POSTGRES_DB "${POSTGRES_DB}"
	option POSTGRES_USER "${POSTGRES_USER}"
	option POSTGRES_PASSWORD "${POSTGRES_PASSWORD}"
	option POSTGRES_HOST "${POSTGRES_HOST}"
	autoconfig_enabled=true
fi

if ${autoconfig_enabled}; then
	if [ -n "${NEXTCLOUD_DATA_DIR}" ]; then
		info "Configuring data directory -> ${NEXTCLOUD_DATA_DIR}"
		option NEXTCLOUD_DATA_DIR "${NEXTCLOUD_DATA_DIR}"
	fi
fi
