#!/bin/sh

set -e

. /scripts/lib.subr

if [ -n "${NEXTCLOUD_ADMIN_USER}" -a -n "${NEXTCLOUD_ADMIN_PASSWORD}" ]; then
	install_options='-n --admin-user "${NEXTCLOUD_ADMIN_USER}" --admin-pass "${NEXTCLOUD_ADMIN_PASSWORD}"'
	if [ -n "${NEXTCLOUD_DATA_DIR}" ]; then
		install_options=${install_options}' --data-dir "${NEXTCLOUD_DATA_DIR}"'
	fi

	install=false
	if [ -n "${SQLITE_DATABASE}" ]; then
		info "Installing with SQLite database ..."
		install_options=$install_options' --database-name "$SQLITE_DATABASE"'
		install=true
	elif [ -n "${MYSQL_DATABASE}" -a -n "${MYSQL_USER}" -a -n "${MYSQL_PASSWORD}" -a -n "${MYSQL_HOST}" ]; then
		info "Installing with MySQL/MariaDB database ..."
		install_options=$install_options' --database mysql --database-name "$MYSQL_DATABASE" --database-user "$MYSQL_USER" --database-pass "$MYSQL_PASSWORD" --database-host "$MYSQL_HOST"'
		install=true
	elif [ -n "${POSTGRES_DB}" -a -n "${POSTGRES_USER}" -a -n "${POSTGRES_PASSWORD}" -a -n "${POSTGRES_HOST}" ]; then
		info "Installing with PostgreSQL database ..."
		install_options=$install_options' --database pgsql --database-name "$POSTGRES_DB" --database-user "$POSTGRES_USER" --database-pass "$POSTGRES_PASSWORD" --database-host "$POSTGRES_HOST"'
		install=true
	fi

	if [ "$install" = true ]; then
		info "Installing Nextcloud ..."

		run_path pre-installation

		info "Starting nextcloud installation"

		max_retries=10
		try=0

		until sh -c "occ maintenance:install $install_options" || [ "$try" -gt "$max_retries" ]
		do
			info "Retrying install (${try}/${max_retries}) ..."
			try=$((try+1))
			sleep 10
		done

		if [ "$try" -gt "$max_retries" ]; then
			info "Installing of nextcloud failed!"
			exit 1
		fi

		if [ -n "${NEXTCLOUD_TRUSTED_DOMAINS}" ]; then
			info "Setting trusted domains ..."
			NC_TRUSTED_DOMAIN_IDX=1
			for DOMAIN in $NEXTCLOUD_TRUSTED_DOMAINS ; do
				DOMAIN=`echo "$DOMAIN" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
				occ config:system:set trusted_domains $NC_TRUSTED_DOMAIN_IDX --value=$DOMAIN
				NC_TRUSTED_DOMAIN_IDX=$((NC_TRUSTED_DOMAIN_IDX+1))
			done
		fi

		run_path post-installation
	else
		warn "Run the web-based installer on first connect!"
	fi
fi

/scripts/init-htaccess.sh

php /scripts/get-version.php > /.nextcloud-done/nextcloud-version

run_path before-starting
