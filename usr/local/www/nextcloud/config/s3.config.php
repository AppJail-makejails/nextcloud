<?php

$ROOTDIR = '/.nextcloud-done/options';
$OBJECTSTORE_S3_BUCKET = $ROOTDIR.'/OBJECTSTORE_S3_BUCKET';
$OBJECTSTORE_S3_SSL = $ROOTDIR.'/OBJECTSTORE_S3_SSL';
$OBJECTSTORE_S3_USEPATH_STYLE = $ROOTDIR.'/OBJECTSTORE_S3_USEPATH_STYLE';
$OBJECTSTORE_S3_LEGACYAUTH = $ROOTDIR.'/OBJECTSTORE_S3_LEGACYAUTH';
$OBJECTSTORE_S3_AUTOCREATE = $ROOTDIR.'/OBJECTSTORE_S3_AUTOCREATE';
$OBJECTSTORE_S3_BUCKET = $ROOTDIR.'/OBJECTSTORE_S3_BUCKET';
$OBJECTSTORE_S3_REGION = $ROOTDIR.'/OBJECTSTORE_S3_REGION';
$OBJECTSTORE_S3_HOST = $ROOTDIR.'/OBJECTSTORE_S3_HOST';
$OBJECTSTORE_S3_PORT = $ROOTDIR.'/OBJECTSTORE_S3_PORT';
$OBJECTSTORE_S3_OBJECT_PREFIX = $ROOTDIR.'/OBJECTSTORE_S3_OBJECT_PREFIX';
$OBJECTSTORE_S3_KEY = $ROOTDIR.'/OBJECTSTORE_S3_KEY';
$OBJECTSTORE_S3_SECRET = $ROOTDIR.'/OBJECTSTORE_S3_SECRET';

if (is_file($OBJECTSTORE_S3_BUCKET)) {
  $use_ssl = is_file($OBJECTSTORE_S3_SSL);
  $use_path = is_file($OBJECTSTORE_S3_USEPATH_STYLE);
  $use_legacyauth = is_file($OBJECTSTORE_S3_LEGACYAUTH);
  $autocreate = is_file($OBJECTSTORE_S3_AUTOCREATE);
  $CONFIG = array(
    'objectstore' => array(
      'class' => '\OC\Files\ObjectStore\S3',
      'arguments' => array(
        'bucket' => file_get_contents($OBJECTSTORE_S3_BUCKET),
        'region' => is_file($OBJECTSTORE_S3_REGION) ? file_get_contents($OBJECTSTORE_S3_REGION) : '',
        'hostname' => is_file($OBJECTSTORE_S3_HOST) ? file_get_contents($OBJECTSTORE_S3_HOST) : '',
        'port' => is_file($OBJECTSTORE_S3_PORT) ? file_get_contents($OBJECTSTORE_S3_PORT) : '',
        'objectPrefix' => is_file($OBJECTSTORE_S3_OBJECT_PREFIX) ? file_get_contents($OBJECTSTORE_S3_OBJECT_PREFIX) : "urn:oid:",
        'autocreate' => $autocreate,
        'use_ssl' => $use_ssl,
        // required for some non Amazon S3 implementations
        'use_path_style' => $use_path,
        // required for older protocol versions
        'legacy_auth' => $use_legacyauth
      )
    )
  );

  if (is_file($OBJECTSTORE_S3_KEY)) {
    $CONFIG['objectstore']['arguments']['key'] = file_get_contents($OBJECTSTORE_S3_KEY);
  } else {
    $CONFIG['objectstore']['arguments']['key'] = '';
  }

  if (is_file($OBJECTSTORE_S3_SECRET)) {
    $CONFIG['objectstore']['arguments']['secret'] = file_get_contents($OBJECTSTORE_S3_SECRET);
  } else {
    $CONFIG['objectstore']['arguments']['secret'] = '';
  }
} 
