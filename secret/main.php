<?php

if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}

## Database settings
$wgDBtype = "mysql";
$wgDBserver = "database";
$wgDBname = "hamichlol_main";
$wgDBuser = "user";
$wgDBpassword = "password";

# MySQL specific settings
$wgDBprefix = "mw_";

# MySQL table options to use during installation or update
$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";

$wgSMTP = array(
	'host' => "",
	'port' => 587,
	'auth' => true,
	'username' => "",
	'password' => ""
);
