<?php

$ROOTDIR = '/.nextcloud-done/options';
$OVERWRITEHOST = $ROOTDIR.'/OVERWRITEHOST';
$OVERWRITEPROTOCOL = $ROOTDIR.'/OVERWRITEPROTOCOL';
$OVERWRITECLIURL = $ROOTDIR.'/OVERWRITECLICURL';
$OVERWRITEWEBROOT = $ROOTDIR.'/OVERWRITEWEBROOT';
$OVERWRITECONDADDR = $ROOTDIR.'/OVERWRITECONDADDR';
$TRUSTED_PROXIES = $ROOTDIR.'/TRUSTED_PROXIES';

if (is_file($OVERWRITEHOST)) {
  $CONFIG['overwritehost'] = file_get_contents($OVERWRITEHOST);
}

if (is_file($OVERWRITEPROTOCOL)) {
  $CONFIG['overwriteprotocol'] = file_get_contents($OVERWRITEPROTOCOL);
}

if (is_file($OVERWRITECLIURL)) {
  $CONFIG['overwrite.cli.url'] = file_get_contents($OVERWRITECLIURL);
}

if (is_file($OVERWRITEWEBROOT)) {
  $CONFIG['overwritewebroot'] = file_get_contents($OVERWRITEWEBROOT);
}

if (is_file($OVERWRITECONDADDR)) {
  $CONFIG['overwritecondaddr'] = file_get_contents($OVERWRITECONDADDR);
}

if (is_file($TRUSTED_PROXIES)) {
  $CONFIG['trusted_proxies'] = array_filter(array_map('trim', explode(' ', file_get_contents($TRUSTED_PROXIES))));
}
