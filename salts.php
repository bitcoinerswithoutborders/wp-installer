<?php

	$salts = file_get_contents('https://api.wordpress.org/secret-key/1.1/salt/');
	
	$config = file_get_contents('|dir_name|/wp-config.php');
	
	$config = str_replace('|SALTS|', $salts, $config);
	
	file_put_contents('|dir_name|/wp-config.php', $config);
