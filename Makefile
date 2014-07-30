#!/bin/bash

dir_name=wp
database_user=wp
database_pw=
database_host=localhost
database_name=wp_db_2305
database_table_prefix=db_fn_
root_url=ma.ke
members_url=mem.bers
new_url=n.ew
protocol=http://
user=www-data
ssh_host=
ssh_user=
ssh_dir=
uploads_dir=
debug=false
sqlite_db_user=
sqlite_db_host=
sqlite_db_lib=

salts=$(shell cat salts.html)

all: update 

install: wp plugins submodules_init wpconfig static update gitignore db

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
	mkdir -p ${dir_name}/${uploads_dir}

	cd ${dir_name}/${uploads_dir}/ \
	&& scp -r ${ssh_user}@${ssh_host}:${ssh_dir}/${uploads_dir}/* .
	
	cd ${dir_name}/c/lib/ \
	&& scp -r ${ssh_user}@${ssh_host}:${ssh_dir}/c/lib/membership/ .

	scp -r ${sqlite_db_user}@${sqlite_db_host}:${sqlite_db_dir} ./${dir_name}/c/lib/bwb-members-migration/assets/sqlite.db


	sudo chown -R ${user}:${user} ${dir_name}/${uploads_dir}

static-own:
	sudo chown -R ${user}:${user} ${dir_name}/${uploads_dir}
	sudo chown -R ${user}:${user} ${dir_name}/${uploads_dir}/*

plugins:
	cd ./${dir_name}/c/lib \
	&& wget https://downloads.wordpress.org/plugin/buddypress.2.0.1.zip \
	&& unzip -o ./buddypress.2.0.1.zip && rm ./buddypress.2.0.1.zip \
	&& wget https://downloads.wordpress.org/plugin/regenerate-thumbnails.zip \
	&& unzip -o ./regenerate-thumbnails.zip && rm ./regenerate-thumbnails.zip \
	&& wget https://downloads.wordpress.org/plugin/wordpress-mu-domain-mapping.0.5.4.3.zip \
	&& unzip -o ./wordpress-mu-domain-mapping.0.5.4.3.zip && rm ./wordpress-mu-domain-mapping.0.5.4.3.zip \
	&& wget http://downloads.wordpress.org/plugin/dbview.zip \
	&& unzip -o ./dbview.zip && rm ./dbview.zip \
	&& wget http://downloads.wordpress.org/plugin/advanced-cron-manager.1.2.zip \
	&& unzip -o ./advanced-cron-manager.1.2.zip && rm ./advanced-cron-manager.1.2.zip \
	&& wget http://downloads.wordpress.org/plugin/adminer.1.3.0.zip \
	&& unzip -o ./adminer.1.3.0.zip && rm ./adminer.1.3.0.zip \
	&& wget http://downloads.wordpress.org/plugin/wordpress-importer.0.6.1.zip \
	&& unzip -o ./wordpress-importer.0.6.1.zip && rm ./wordpress-importer.0.6.1.zip \

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
		./regenerate-thumbnails \
		./wordpress-mu-domain-mapping \
		./timber-library \
		./advanced-cron-manager \
		./adminer \
		./wordpress-importer

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

gitignore:
	mkdir -p ./backup
	cp .gitignore ./backup/.gitignore

	sed -i \
		-e "s%|dir_name|%${dir_name}%g" \
		.gitignore

db:
	mkdir -p build

	#cp db.php build/db.php
	#sed -i \
	#	-e "s%|database_name|%${database_name}%g" \
	#	-e "s%|database_user|%${database_user}%g" \
	#	-e "s%|database_pw|%${database_pw}%g" \
	#	-e "s%|database_host|%${database_host}%g" \
	#	-e "s%|protocol|%${protocol}%g" \
	#	build/db.php
	#php -f build/db.php

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

	mysql -u ${database_user} -p${database_pw} < build/db.sql

wpconfig:
	mkdir -p build

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
		-e "s%|debug|%${debug}%g" \
		-e "s%|database_name|%${database_name}%g" \
		-e "s%|database_user|%${database_user}%g" \
		-e "s%|database_pw|%${database_pw}%g" \
		-e "s%|uploads_dir|%${uploads_dir}%g" \
		-e "s%|database_host|%${database_host}%g" \
		-e "s%|database_table_prefix|%${database_table_prefix}%g" \
		${dir_name}/wp-config.php

clean:
	cp ./backup/.gitignore ./.gitignore
	rm -rf ./${dir_name} ./build ./backup

