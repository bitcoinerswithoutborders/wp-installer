#!/bin/bash
#make:

dir_name=wp
database_name=db_name_2306
database_table_prefix=db_table_prefix

.PHONY:
	clean
	db
	update
	plugins
	themes
	install

all: update 

install: plugins themes update db

plugins:
	git clone git@github.com:bitcoinerswithoutborders/wp ${dir_name}

	cd ./${dir_name}/c/lib \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-admin \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-members \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-staff \
	&& git submodule add git@github.com:bitcoinerswithoutborders/timber \
	&& git submodule add git@github.com:bitcoinerswithoutborders/wp-less \
	&& git submodule update --init \

	&& wget https://downloads.wordpress.org/plugin/buddypress.2.0.1.zip \
	&& unzip c/lib/buddypress.2.0.1.zip && rm /c/libbuddypress.2.0.1.zip \
	&& wget http://downloads.wordpress.org/plugin/advanced-custom-fields.zip \
	&& unzip c/lib/advanced-custom-fields.zip && rm /c/lib/advanced-custom-fields.zip \
	&& wget http://downloads.wordpress.org/plugin/webriti-smtp-mail.1.2.zip \
	&& unzip c/lib/webriti-smtp-mail.1.2.zip && rm /c/lib/webriti-smtp-mail.1.2.zip \
	&& wget http://downloads.wordpress.org/plugin/regenerate-thumbnails.zip \
	&& unzip c/lib/regenerate-thumbnails.zip && rm /c/lib/regenerate-thumbnails.zip \
	&& wget http://downloads.wordpress.org/plugin/wordpress-mu-domain-mapping.0.5.4.3.zip \
	&& unzip c/lib/wordpress-mu-domain-mapping.0.5.4.3.zip && rm /c/lib/wordpress-mu-domain-mapping.0.5.4.3.zip \
	#missing here:
	# logout-redirect => wpmu
	# membership => wpmu

themes:
	cd ./${dir_name}/c/themes \
	&& git submodule add -b members git@github.com:bitcoinfoundation/btcf_classic \
	&& git submodule add -b members git@github.com:bitcoinfoundation/bwbmembers \


update:
	cd ./${dir_name}/ \
	&& git pull \
	&& git submodule update

db:
	mkdir -p build

	cp db.php build/db.php
	sed -i "s%|database_name|%${database_name}%g" build/db.php
	php -f build/db.php

	cp db.sql build/db.sql
	sed -i "s%|new_table_prefix|%${database_table_prefix}%g" build/db.sql
	mysql -u root ${database_name} < build/db.sql

clean:
	rm -rf ./${dir_name}
