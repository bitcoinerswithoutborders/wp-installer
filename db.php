<?php
	$db_name = '|database_name|';
	$db_server = '|database_host|';
	$db_user = '|database_user|';
	$db_pass = '|database|pw|';

	$mysqli = new mysqli($db_server, $db_user, $db_pass);

	//check connection
	if ($mysqli->connect_errno) :
		printf("Connect failed: %s\n", $mysqli->connect_error);
		exit();
	endif;

	$db = $mysqli->query('SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = "' . $db_name . '"');

	if ( $db->num_rows > 0 ) :
		print('Database already exists' . "\n");
		exit();
	endif;

	$db_return = $mysqli->query('CREATE DATABASE ' . $db_name . ';');

	$add_db_message = " succeeded";

	if ( empty($db_return) ) :
		$add_db_message = " failed";
	endif;

	print 'added database' . $db_name . ' and' . $add_db_message . "\n";
