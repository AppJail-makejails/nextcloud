<?php
$autoconfig_enabled = false;

$ROOTDIR = '/.nextcloud-done/options';
// SQLite
$SQLITE_DATABASE = $ROOTDIR.'/SQLITE_DATABASE';
// MySQL
$MYSQL_DATABASE = $ROOTDIR.'/MYSQL_DATABASE';
$MYSQL_USER = $ROOTDIR.'/MYSQL_USER';
$MYSQL_PASSWORD = $ROOTDIR.'/MYSQL_PASSWORD';
$MYSQL_HOST = $ROOTDIR.'/MYSQL_HOST';
// PostgreSQL
$POSTGRES_DB = $ROOTDIR.'/POSTGRES_DB';
$POSTGRES_USER = $ROOTDIR.'/POSTGRES_USER';
$POSTGRES_PASSWORD = $ROOTDIR.'/POSTGRES_PASSWORD';
$POSTGRES_HOST = $ROOTDIR.'/POSTGRES_HOST';
// Data directory.
$NEXTCLOUD_DATA_DIR = $ROOTDIR.'/NEXTCLOUD_DATA_DIR';

if (is_file($SQLITE_DATABASE)) {
  $AUTOCONFIG['dbtype'] = 'sqlite';
  $AUTOCONFIG['dbname'] = file_get_contents($SQLITE_DATABASE);
  $autoconfig_enabled = true;
} elseif (is_file($MYSQL_DATABASE) && is_file($MYSQL_USER) && is_file($MYSQL_PASSWORD) && is_file($MYSQL_HOST)) {
  $AUTOCONFIG['dbtype'] = 'mysql';
  $AUTOCONFIG['dbname'] = file_get_contents($MYSQL_DATABASE);
  $AUTOCONFIG['dbuser'] = file_get_contents($MYSQL_USER);
  $AUTOCONFIG['dbpass'] = file_get_contents($MYSQL_PASSWORD);
  $AUTOCONFIG['dbhost'] = file_get_contents($MYSQL_HOST);
  $autoconfig_enabled = true;
} elseif (is_file($POSTGRES_DB) && is_file($POSTGRES_USER) && is_file($POSTGRES_PASSWORD) && is_file($POSTGRES_HOST)) {
  $AUTOCONFIG['dbtype'] = 'pgsql';
  $AUTOCONFIG['dbname'] = file_get_contents($POSTGRES_DB);
  $AUTOCONFIG['dbuser'] = file_get_contents($POSTGRES_USER);
  $AUTOCONFIG['dbpass'] = file_get_contents($POSTGRES_PASSWORD);
  $AUTOCONFIG['dbhost'] = file_get_contents($POSTGRES_HOST);
  $autoconfig_enabled = true;
}

if ($autoconfig_enabled) {
  if (is_file($NEXTCLOUD_DATA_DIR)) {
    $AUTOCONFIG['directory'] = file_get_contents($NEXTCLOUD_DATA_DIR);
  } else {
    $AUTOCONFIG['directory'] = '/usr/local/www/nextcloud/data';
  }
}
