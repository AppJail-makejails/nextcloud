<?php

$ROOTDIR = '/.nextcloud-done/options';
$SMTP_HOST = $ROOTDIR.'/SMTP_HOST';
$SMTP_PORT = $ROOTDIR.'/SMTP_PORT';
$SMTP_SECURE = $ROOTDIR.'/SMTP_SECURE';
$SMTP_PASSWORD = $ROOTDIR.'/SMTP_PASSWORD';
$SMTP_AUTHTYPE = $ROOTDIR.'/SMTP_AUTHTYPE';
$SMTP_NAME = $ROOTDIR.'/SMTP_NAME';
$MAIL_FROM_ADDRESS = $ROOTDIR.'/MAIL_FROM_ADDRESS';
$MAIL_DOMAIN = $ROOTDIR.'/MAIL_DOMAIN';

if (is_file($SMTP_HOST) && is_file($MAIL_FROM_ADDRESS) && is_file($MAIL_DOMAIN)) {
  $CONFIG = array (
    'mail_smtpmode' => 'smtp',
    'mail_smtphost' => file_get_contents($SMTP_HOST),
    'mail_smtpport' => is_file($SMTP_PORT) ? (int)file_get_contents($SMTP_PORT) : (is_file($SMTP_SECURE) ? 465 : 25),
    'mail_smtpsecure' => is_file($SMTP_SECURE) ? file_get_contents($SMTP_SECURE) : '',
    'mail_smtpauth' => is_file($SMTP_NAME) && is_file($SMTP_PASSWORD),
    'mail_smtpauthtype' => is_file($SMTP_AUTHTYPE) ? file_get_contents($SMTP_AUTHTYPE) : 'LOGIN',
    'mail_smtpname' => is_file($SMTP_NAME) ? file_get_contents($SMTP_NAME) : '',
    'mail_from_address' => file_get_contents($MAIL_FROM_ADDRESS),
    'mail_domain' => file_get_contents($MAIL_DOMAIN),
  );

  if (is_file($SMTP_PASSWORD)) {
      $CONFIG['mail_smtppassword'] = file_get_contents($SMTP_PASSWORD);
  } else {
      $CONFIG['mail_smtppassword'] = '';
  }
}
