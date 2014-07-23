#!/bin/bash

dir_name=wp
database_user=root
database_pw=
database_host=localhost
database_name=db_name_2305
database_table_prefix=db_table_prefix_
root_url=er.is
members_url=mem.bers
whiteboard_url=n.ew
protocol=http://

.PHONY:
	wp
	plugins
	submodules
	themes
	uninstall
	uninstall_plugins
	uninstall_themes
	update
	db
	wpconfig
	clean


all: update 

install: wp plugins submodules wpconfig update db

uninstall: uninstall_plugins uninstall_themes



wp:
	mkdir -p ${dir_name}
	git clone git@github.com:bitcoinerswithoutborders/wp ${dir_name}

plugins:
	cd ./${dir_name}/c/lib \
	&& wget https://downloads.wordpress.org/plugin/buddypress.2.0.1.zip \
	&& unzip -o ./buddypress.2.0.1.zip && rm ./buddypress.2.0.1.zip \
	&& wget https://downloads.wordpress.org/plugin/advanced-custom-fields.zip \
	&& unzip -o ./advanced-custom-fields.zip && rm ./advanced-custom-fields.zip \
	&& wget https://downloads.wordpress.org/plugin/webriti-smtp-mail.1.2.zip \
	&& unzip -o ./webriti-smtp-mail.1.2.zip && rm ./webriti-smtp-mail.1.2.zip \
	&& wget https://downloads.wordpress.org/plugin/regenerate-thumbnails.zip \
	&& unzip -o ./regenerate-thumbnails.zip && rm ./regenerate-thumbnails.zip \
	&& wget https://downloads.wordpress.org/plugin/wordpress-mu-domain-mapping.0.5.4.3.zip \
	&& unzip -o ./wordpress-mu-domain-mapping.0.5.4.3.zip && rm ./wordpress-mu-domain-mapping.0.5.4.3.zip \
	&& wget https://downloads.wordpress.org/plugin/wp-email-login.zip \
	&& unzip -o ./wp-email-login.zip && rm ./wp-email-login.zip \
	&& wget https://downloads.wordpress.org/plugin/timber-library.zip \
	&& unzip -o ./timber-library.zip && rm ./timber-library.zip \

submodules:
	cd ./${dir_name}/c/lib \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-admin \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-members \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-staff \
	&& git submodule add git@github.com:bitcoinerswithoutborders/wp-less \
	&& git submodule add git@github.com:bitcoinerswithoutborders/wp-members-authentication-bridge \
	&& git submodule add git@github.com:bitcoinerswithoutborders/wp-ip.board-user-bridge \
	&& git submodule add git@github.com:benhuson/countries \
	&& git submodule update --init \
	#missing here: membership

themes:
	cd ./${dir_name}/c/themes \
	&& git submodule add -b members git@github.com:bitcoinfoundation/btcf_classic 
	&& git submodule add -b members git@github.com:bitcoinfoundation/bwb-bp-theme bwbmembers \




uninstall_plugins:
	cd ./${dir_name}/c/lib \
	&& rm -rf \
		./buddypress \
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
	&& git submodule deinit wp-members-authentication-bridge \
	&& git submodule deinit wp-ip.board-user-bridge \

uninstall_themes:
	cd ./${dir_name}/c/themes \
	&& git submodule deinit btcf_classic \
	&& git submodule deinit bwb_members \

update:
	cd ./${dir_name}/ \
	&& git pull \
	&& git submodule update \

db:
	mkdir -p build

	cp db.php build/db.php
	sed -i \
		-e "s%|database_name|%${database_name}%g" \
		-e "s%|database_user|%${database_user}%g" \
		-e "s%|database_pw|%${database_pw}%g" \
		-e "s%|database_host|%${database_host}%g" \
		build/db.php
	php -f build/db.php

	cp db.sql build/db.sql
	sed -i \
		-e "s%|database_table_prefix|%${database_table_prefix}%g" \
		-e "s%|site_url|%${site_url}%g" \
		-e "s%|database_user|%${database_user}%g" \
		-e "s%|database_pw|%${database_pw}%g" \
		build/db.sql

	mysql -u root < build/db.sql

wpconfig:
	echo "wpconfig is not working correctly. look into ${dir_name}/wp-config.php at the auth keys."

	cp ${dir_name}/wp-config-sample.php ${dir_name}/wp-config.php

	sed -i \
		-e "s%|AUTH_KEY|%define('AUTH_KEY', '${shell makepasswd -m 64 -c 'A-Za-z0-9~!#^&*-_=+'}');%" \
		-e "s%|SECURE_AUTH_KEY|%define('SECURE_AUTH_KEY', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!#^&*-_=+')');%" \
		-e "s%|LOGGED_IN_KEY|%define('LOGGED_IN_KEY', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!#^&*-_=+')');%" \
		-e "s%|NONCE_KEY|%define('NONCE_KEY', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!#^&*-_=+')');%" \
		-e "s%|AUTH_SALT|%define('AUTH_SALT', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!#^&*-_=+')');%" \
		-e "s%|SECURE_AUTH_SALT|%define('SECURE_AUTH_SALT', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!@#^&*-_=+')');%" \
		-e "s%|LOGGED_IN_SALT|%define('LOGGED_IN_SALT', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!@#^&*-_=+')');%" \
		-e "s%|NONCE_SALT|%define('NONCE_SALT', '$(shell makepasswd -m 64 -c 'A-Za-z0-9~!@#^&*-_=+')');%" \
		-e "s%|site_url|%${site_url}%g" \
		-e "s%|database_name|%${database_name}%g" \
		-e "s%|database_user|%${database_user}%g" \
		-e "s%|database_pw|%${database_pw}%g" \
		-e "s%|database_host|%${database_host}%g" \
		-e "s%|database_table_prefix|%${database_table_prefix}%g" \
		${dir_name}/wp-config.php
	
	
clean:
	rm -rf ./${dir_name} ./build

