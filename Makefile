#!/bin/bash
#make:

.PHONY: 
	clean
	db
	update

all:
	git clone git@github.com:bitcoinerswithoutborders/wp

	cd ./wp/ \
	&& git submodule add -b members git@github.com:bitcoinfoundation/btcf_classic c/themes/btcf_classic \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-admin c/lib/bwb-admin \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-members c/lib/bwb-members \
	&& git submodule add git@github.com:bitcoinerswithoutborders/bwb-staff c/lib/bwb-staff \
	&& git submodule add git@github.com:bitcoinerswithoutborders/timber c/lib/timber \
	&& git submodule add git@github.com:bitcoinerswithoutborders/wp-less c/lib/wp-less \
	&& git submodule update --init; \
	
update:
	cd ./wp/ \
	&& git pull \
	&& git submodule update

db:
	php -f db.php

clean:
	rm -rf ./wp
