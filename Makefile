#!/bin/bash

dir_name=wp
database_user=root
database_pw=
database_host=localhost
database_name=db_name_2305
database_table_prefix=db_table_prefix_
root_url=er.is
members_url=mem.bers
new_url=n.ew
protocol=http://
user=apache


salts=$(shell cat salts.html)

all: update 

install: wp plugins submodules_init wpconfig update db

uninstall: uninstall_plugins uninstall_themes


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

wp:
	mkdir -p ${dir_name}
	git clone git@github.com:bitcoinerswithoutborders/wp ${dir_name}
	
static:
	mkdir -p ${dir_name}/static

	cd ${dir_name}/static/ \
	&& scp -r root@mercury.bitcoinfoundation.org:/var/www/bitcoinfoundation.org/static/* .

	cd ${dir_name}/c/lib/ \
	&& scp -r root@mercury.bitcoinfoundation.org:/var/www/bitcoinfoundation.org/c/lib/membership/ .

	sudo chown ${user}:${user} ${dir_name}/static
	

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

submodules:
	cd ./${dir_name}/c/lib \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-admin \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-members \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-staff \
	&& git submodule add git@github.com:bitcoinerswithoutborders/wp-less \
	&& git submodule add git@github.com:bitcoinerswithoutborders/timber \
	&& git submodule add git@github.com:bitcoinerswithoutborders/wp-members-authentication-bridge \
	&& git submodule add git@github.com:bitcoinerswithoutborders/wp-ip.board-user-bridge \
	&& git submodule add git@github.com:benhuson/countries \
	&& git submodule update --init \
	#missing here: membership
	
submodules_init:
	cd ./${dir_name} \
	&& git submodule update --init

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
		./timber-library \

uninstall_submodules:
	cd ./${dir_name}/c/lib \
	&& git submodule deinit bwb-admin \
	&& git submodule deinit bwb-members \
	&& git submodule deinit bwb-staff \
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
		-e "s%|protocol|%${protocol}%g" \
		build/db.php
	php -f build/db.php

	cp db.sql build/db.sql
	sed -i \
		-e "s%|database_name|%${database_name}%g" \
		-e "s%|database_table_prefix|%${database_table_prefix}%g" \
		-e "s%|root_url|%${root_url}%g" \
		-e "s%|members_url|%${members_url}%g" \
		-e "s%|new_url|%${new_url}%g" \
		-e "s%|database_user|%${database_user}%g" \
		-e "s%|database_pw|%${database_pw}%g" \
		-e "s%|protocol|%${protocol}%g" \
		build/db.sql

	mysql -u root < build/db.sql

wpconfig:
	mkdir -p build
	error="wpconfig is not working correctly. look into ${dir_name}/wp-config.php at the auth keys."

	cp ${dir_name}/wp-config-sample.php ${dir_name}/wp-config.php

	# get salts from wordpress and replace in wp-config using php script
	cp salts.php build/salts.php
	sed -i \
		-e "s%|dir_name|%${dir_name}%g" \
		build/salts.php

	php -f build/salts.php


	sed -i \
		-e "s%|root_url|%${root_url}%g" \
		-e "s%|members_url|%${members_url}%g" \
		-e "s%|new_url|%${new_url}%g" \
		-e "s/|database_name|/${database_name}/g" \
		-e "s/|database_user|/${database_user}/g" \
		-e "s/|database_pw|/${database_pw}/g" \
		-e "s/|database_host|/${database_host}/g" \
		-e "s/|database_table_prefix|/${database_table_prefix}/g" \
		${dir_name}/wp-config.php

clean:
	rm -rf ./${dir_name} ./build

