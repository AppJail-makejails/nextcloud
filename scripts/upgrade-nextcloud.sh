#!/bin/sh

set -e

. /scripts/lib.subr

installed_version=`head -1 -- /.nextcloud-done/nextcloud-version`
image_version=`php /scripts/get-version.php`

if version_greater "${installed_version}" "${image_version}"; then
    err "Can't upgrade Nextcloud because the version of the data (${installed_version}) is higher than the AppJail image version (${image_version})."
    exit 1
fi

if version_greater "${image_version}" "${installed_version}"; then
	if [ "${image_version%%.*}" -gt "$((${installed_version%%.*} + 1))" ]; then
		err "Can't start Nextcloud because upgrading from ${installed_version} to ${image_version} is not supported."
		err "It is only possible to upgrade one major version at a time. For example, if you want to upgrade from version 14 to 16, you will have to upgrade from version 14 to 15, then from 15 to 16."
		exit 1
	fi

	info "Upgrading Nextcloud from ${installed_version} to ${image_version}"

	list_before=`TMPDIR=/tmp mktemp -t nextcloud`

	occ app:list | sed -n "/Enabled:/,/Disabled:/p" > "${list_before}"

	run_path pre-upgrade

	occ upgrade

	list_after=`TMPDIR=/tmp mktemp -t nextcloud`

	occ app:list | sed -n "/Enabled:/,/Disabled:/p" > "${list_after}"

	info "The following apps have been disabled:"
	diff "${list_before}" "${list_after}" | grep '<' | cut -d- -f2 | cut -d: -f1
	rm -f "${list_before}" "${list_after}"

	run_path post-upgrade

	php /scripts/get-version.php > /.nextcloud-done/nextcloud-version
fi

/scripts/init-htaccess.sh

run_path before-starting
