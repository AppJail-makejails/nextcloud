#!/bin/sh

set -e

. /scripts/lib.subr

if ! [ -n "${SMTP_HOST}" -a -n "${MAIL_FROM_ADDRESS}" -a -n "${MAIL_DOMAIN}" ]; then
	return 0
fi

info "Configuring smtp.config.php ..."

option SMTP_HOST "${SMTP_HOST}"
option MAIL_FROM_ADDRESS "${MAIL_FROM_ADDRESS}"
option MAIL_DOMAIN "${MAIL_DOMAIN}"

if [ -n "${SMTP_PORT}" ]; then
	option SMTP_PORT "${SMTP_PORT}"
fi

if [ -n "${SMTP_SECURE}" ]; then
	option SMTP_SECURE
fi

if [ -n "${SMTP_NAME}" ]; then
	option SMTP_NAME "${SMTP_NAME}"
fi

if [ -n "${SMTP_AUTHTYPE}" ]; then
	option SMTP_AUTHTYPE "${SMTP_AUTHTYPE}"
fi

if [ -n "${SMTP_PASSWORD}" ]; then
	option SMTP_PASSWORD "${SMTP_PASSWORD}"
fi
