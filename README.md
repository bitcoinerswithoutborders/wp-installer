wp-installer
============

Our wordpress install repository.

installation instructions:

    git clone git@github.com:bitcoinerswithoutborders/wp-installer
    cd wp-installer
    make


this will:

git clone git@github.com:bitcoinerswithoutborders/wp

add all needed plugins and themes as submodules, init and update them

create the database needed for wordpress

//todo:
add .sql file with bootstrap data

activate wordpress by

setting the database user, password, server and other variables in it,
regenerating the auth keys
copying wp-config-sample.php to wp-config.php

