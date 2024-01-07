#!/bin/sh

set -e

. /scripts/lib.subr

mkdir -p "/.nextcloud-done"
mkdir -p "/.nextcloud-done/options"

rm -f "/.nextcloud-done/options/*"

info "Configuring ..."

for script in /scripts/config/*.sh; do
	"${script}"
done

if [ -f "/.nextcloud-done/nextcloud-version" ]; then
	/scripts/upgrade-nextcloud.sh
else
	/scripts/install-nextcloud.sh
fi
