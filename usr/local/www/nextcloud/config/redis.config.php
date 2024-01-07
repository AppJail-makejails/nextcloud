<?php

$ROOTDIR = '/.nextcloud-done/options';
$REDIS_HOST = $ROOTDIR.'/REDIS_HOST';
$REDIS_HOST_PASSWORD = $ROOTDIR.'/REDIS_HOST_PASSWORD';
$REDIS_HOST_PORT = $ROOTDIR.'/REDIS_HOST_PORT';

if (is_file($REDIS_HOST)) {
  $CONFIG = array(
    'memcache.distributed' => '\OC\Memcache\Redis',
    'memcache.locking' => '\OC\Memcache\Redis',
    'redis' => array(
      'host' => file_get_contents($REDIS_HOST),
      'password' => is_file($REDIS_HOST_PASSWORD) ? file_get_contents($REDIS_HOST_PASSWORD) : '',
    ),
  );

  if (is_file($REDIS_HOST_PORT)) {
    $CONFIG['redis']['port'] = file_get_contents($REDIS_HOST_PORT);
  } elseif (file_get_contents($REDIS_HOST)[0] != '/') {
    $CONFIG['redis']['port'] = 6379;
  }
}
