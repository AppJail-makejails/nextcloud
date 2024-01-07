<?php

$ROOTDIR = '/.nextcloud-done/options';
$LOGTIMEZONE = $ROOTDIR.'/LOGTIMEZONE';

$CONFIG = array (
  'logfile' => '/var/log/nextcloud/nextcloud.log',
  'logtimezone' => is_file($LOGTIMEZONE) ? file_get_contents($LOGTIMEZONE) : 'UTC',
);
