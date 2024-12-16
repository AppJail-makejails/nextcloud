#!/bin/sh

BASEDIR=`dirname -- "$0"` || exit $?
BASEDIR=`realpath -- "${BASEDIR}"` || exit $?

. "${BASEDIR}/update.conf"

set -xe
set -o pipefail

cat -- "${BASEDIR}/Makejail.template" |\
    sed -E \
        -e "s/%%TAG1%%/${TAG1}/g" \
        -e "s/%%PHP_TAG%%/${PHP_TAG}/g" > "${BASEDIR}/../Makejail"

cat -- "${BASEDIR}/install-nextcloud.makejail.template" |\
    sed -Ee "s/%%PHP_TAG%%/${PHP_TAG}/g" > "${BASEDIR}/../install-nextcloud.makejail"

cat -- "${BASEDIR}/README.md.template" |\
    sed -E \
        -e "s/%%TAG1%%/${TAG1}/g" \
        -e "s/%%TAG2%%/${TAG2}/g" \
        -e "s/%%PHP_TAG%%/${PHP_TAG}/g" > "${BASEDIR}/../README.md"
