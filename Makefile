#!/bin/bash

dir_name=wp
database_user=root
database_pw=
database_host=localhost
database_name=db_name_2306
database_table_prefix=db_table_prefix
site_url=ma.ke
site_protocol=http://

.PHONY:
	clean
	db
	update
	plugins
	themes
	install

all: update 

install: wp plugins themes wpconfig update db

wp:
	git clone git@github.com:bitcoinerswithoutborders/wp ${dir_name}

plugins:
	cd ./${dir_name}/c/lib \
	&& wget https://downloads.wordpress.org/plugin/buddypress.2.0.1.zip \
	&& unzip ./buddypress.2.0.1.zip && rm ./buddypress.2.0.1.zip \
	&& wget http://downloads.wordpress.org/plugin/advanced-custom-fields.zip \
	&& unzip ./advanced-custom-fields.zip && rm ./advanced-custom-fields.zip \
	&& wget http://downloads.wordpress.org/plugin/webriti-smtp-mail.1.2.zip \
	&& unzip ./webriti-smtp-mail.1.2.zip && rm ./webriti-smtp-mail.1.2.zip \
	&& wget http://downloads.wordpress.org/plugin/regenerate-thumbnails.zip \
	&& unzip ./regenerate-thumbnails.zip && rm ./regenerate-thumbnails.zip \
	&& wget http://downloads.wordpress.org/plugin/wordpress-mu-domain-mapping.0.5.4.3.zip \
	&& unzip ./wordpress-mu-domain-mapping.0.5.4.3.zip && rm ./wordpress-mu-domain-mapping.0.5.4.3.zip \
	&& wget http://downloads.wordpress.org/plugin/wp-email-login.zip \
	&& unzip ./wp-email-login.zip && rm ./wp-email-login.zip \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-admin \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-members \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-staff \
	&& git submodule add git@github.com:bitcoinerswithoutborders/timber \
	&& git submodule add git@github.com:bitcoinerswithoutborders/wp-less \
	&& git submodule update --init \
	#missing here: logout-redirect wpmu membership wpmu
	
themes:
	cd ./${dir_name}c/themes \
	&& git submodule add -b members git@github.com:bitcoinfoundation/btcf_classic 
	&& git submodule add -b members git@github.com:bitcoinfoundation/bwb-bp-theme bwbmembers \


uninstall: uninstall plugins uninstall_themes


uninstall_plugins:
	cd ./wp/c/lib \
	&& rm -rf \
		./buddypress  \
		./advanced-custom-fields \
		./webriti-smtp-mail \
		./regenerate-thumbnails \
		./wordpress-mu-domain-mapping \
		./wp-email-login \
	&& git submodule deinit bwb-admin \
	&& git submodule deinit bwb-members \
	&& git submodule deinit bwb-staff \
	&& git submodule deinit timber \
	&& git submodule deinit wp-less \

uninstall_themes:
	cd ./wp/c/themes \
	&& git submodule deinit btcf_classic \
	&& git submodule deinit bwb_members \

update:
	cd ./${dir_name}/ \
	&& git pull \
	&& git submodule update \

db:
	mkdir -p build

	cp db.php build/db.php
	sed -i "s%|database_name|%${database_name}%g" build/db.php
	sed -i "s%|database_user|%${database_user}%g" build/db.php
	sed -i "s%|database_pw|%${database_pw}%g" build/db.php
	sed -i "s%|database_host|%${database_host}%g" build/db.php
	php -f build/db.php

	cp db.sql build/db.sql
	sed -i "s%|database_table_prefix|%${database_table_prefix}%g" build/db.sql
	sed -i "s%|site_url|%${site_url}%g" build/db.sql
	
	sed -i "s%|database_user|%${database_user}%g" build/db.sql
	sed -i "s%|database_pw|%${database_pw}%g" build/db.sql

	mysql -u root ${database_name} < build/db.sql

wpconfig:
	echo "wpconfig is not working correctly. look into wp/wp-config.php at the auth keys."

	cp wp/wp-config-sample.php wp/wp-config.php
	sed -i "s%|AUTH_KEY|%define('AUTH_KEY', '${shell makepasswd -m 64 -c 'A-Za-z0-9~!#^&*-_=+'}');%" wp/wp-config.php
	sed -i "s%|SECURE_AUTH_KEY|%define('SECURE_AUTH_KEY', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!#^&*-_=+')');%" wp/wp-config.php
	sed -i "s%|LOGGED_IN_KEY|%define('LOGGED_IN_KEY', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!#^&*-_=+')');%" wp/wp-config.php
	sed -i "s%|NONCE_KEY|%define('NONCE_KEY', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!#^&*-_=+')');%" wp/wp-config.php
	sed -i "s%|AUTH_SALT|%define('AUTH_SALT', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!#^&*-_=+')');%" wp/wp-config.php
	sed -i "s%|SECURE_AUTH_SALT|%define('SECURE_AUTH_SALT', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!@#^&*-_=+')');%" wp/wp-config.php
	sed -i "s%|LOGGED_IN_SALT|%define('LOGGED_IN_SALT', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!@#^&*-_=+')');%" wp/wp-config.php
	sed -i "s%|NONCE_SALT|%define('NONCE_SALT', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!@#^&*-_=+')');%" wp/wp-config.php

	sed -i "s%|site_url|%${site_url}%g" wp/wp-config.php

	sed -i "s%|database_name|%${database_name}%g" wp/wp-config.php
	sed -i "s%|database_user|%${database_user}%g" wp/wp-config.php
	sed -i "s%|database_pw|%${database_pw}%g" wp/wp-config.php
	sed -i "s%|database_host|%${database_host}%g" wp/wp-config.php
	
	sed -i "s%|database_table_prefix|%${database_table_prefix}%g" wp/wp-config.php
	
	
clean:
	rm -rf ./${dir_name} ./build
