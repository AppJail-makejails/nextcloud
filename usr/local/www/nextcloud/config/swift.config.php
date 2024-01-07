<?php

$ROOTDIR = '/.nextcloud-done/options';
$OBJECTSTORE_SWIFT_URL = $ROOTDIR.'/OBJECTSTORE_SWIFT_URL';
$OBJECTSTORE_SWIFT_AUTOCREATE = $ROOTDIR.'/OBJECTSTORE_SWIFT_AUTOCREATE';
$OBJECTSTORE_SWIFT_USER_NAME = $ROOTDIR.'/OBJECTSTORE_SWIFT_USER_NAME';
$OBJECTSTORE_SWIFT_USER_PASSWORD = $ROOTDIR.'/OBJECTSTORE_SWIFT_USER_PASSWORD';
$OBJECTSTORE_SWIFT_USER_DOMAIN = $ROOTDIR.'/OBJECTSTORE_SWIFT_USER_DOMAIN';
$OBJECTSTORE_SWIFT_PROJECT_NAME = $ROOTDIR.'/OBJECTSTORE_SWIFT_PROJECT_NAME';
$OBJECTSTORE_SWIFT_PROJECT_DOMAIN = $ROOTDIR.'/OBJECTSTORE_SWIFT_PROJECT_DOMAIN';
$OBJECTSTORE_SWIFT_SERVICE_NAME = $ROOTDIR.'/OBJECTSTORE_SWIFT_SERVICE_NAME';
$OBJECTSTORE_SWIFT_REGION = $ROOTDIR.'/OBJECTSTORE_SWIFT_REGION';
$OBJECTSTORE_SWIFT_CONTAINER_NAME = $ROOTDIR.'/OBJECTSTORE_SWIFT_CONTAINER_NAME';

if (is_file($OBJECTSTORE_SWIFT_URL)) {
  $autocreate = is_file($OBJECTSTORE_SWIFT_AUTOCREATE);
  $CONFIG = array(
    'objectstore' => [
      'class' => 'OC\\Files\\ObjectStore\\Swift',
      'arguments' => [
        'autocreate' => $autocreate,
        'user' => [
          'name' => is_file($OBJECTSTORE_SWIFT_USER_NAME) ? file_get_contents($OBJECTSTORE_SWIFT_USER_NAME) : '',
          'password' => is_file($OBJECTSTORE_SWIFT_USER_PASSWORD) ? file_get_contents($OBJECTSTORE_SWIFT_USER_PASSWORD) : '',
          'domain' => [
            'name' => is_file($OBJECTSTORE_SWIFT_USER_DOMAIN) ? file_get_contents($OBJECTSTORE_SWIFT_USER_DOMAIN) : 'Default',
          ],
        ],
        'scope' => [
          'project' => [
            'name' => is_file($OBJECTSTORE_SWIFT_PROJECT_NAME) ? file_get_contents($OBJECTSTORE_SWIFT_PROJECT_NAME) : '',
            'domain' => [
              'name' => is_file($OBJECTSTORE_SWIFT_PROJECT_DOMAIN) ? file_get_contents($OBJECTSTORE_SWIFT_PROJECT_DOMAIN) : 'Default',
            ],
          ],
        ],
        'serviceName' => is_file($OBJECTSTORE_SWIFT_SERVICE_NAME) ? file_get_contents($OBJECTSTORE_SWIFT_SERVICE_NAME) : 'swift',
        'region' => is_file($OBJECTSTORE_SWIFT_REGION) ? file_get_contents($OBJECTSTORE_SWIFT_REGION) : '',
        'url' => is_file($OBJECTSTORE_SWIFT_URL) ? file_get_contents($OBJECTSTORE_SWIFT_URL) : '',
        'bucket' => is_file($OBJECTSTORE_SWIFT_CONTAINER_NAME) ? file_get_contents($OBJECTSTORE_SWIFT_CONTAINER_NAME) : '',
      ]
    ]
  );
}
