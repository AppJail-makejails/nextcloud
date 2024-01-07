# Update htaccess after init if requested
if [ -n "${NEXTCLOUD_INIT_HTACCESS}" ]; then
	occ maintenance:update:htaccess
fi
