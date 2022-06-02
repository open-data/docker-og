#!/bin/bash

#
# Variables
#

# text
Cyan='\033[0;36m'
Yellow='\033[1;33m'
Red='\033[0;31m'
Orange='\033[0;33m'
Green='\033[0;32m'
NC='\033[0;0m'
EOL='\n'
SPACER='\n\n'
INDENT='    '
BOLD='\033[1m'
HAIR='\033[0m'

# general flags
exitScript='false'

psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
    CREATE USER postgres SUPERUSER;
    CREATE DATABASE postgres WITH OWNER postgres;
    CREATE USER homestead;
    ALTER USER homestead PASSWORD 'secret';
    CREATE USER homestead_reader;
    ALTER USER homestead_reader PASSWORD 'secret';
    CREATE DATABASE og_drupal_local__${PROJECT_ID};
    CREATE DATABASE og_ckan_portal_local__${PROJECT_ID};
    CREATE DATABASE og_ckan_portal_ds_local__${PROJECT_ID};
    CREATE DATABASE og_ckan_registry_local__${PROJECT_ID};
    CREATE DATABASE og_ckan_registry_ds_local__${PROJECT_ID};
    GRANT ALL PRIVILEGES ON DATABASE og_drupal_local__${PROJECT_ID} TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_local__${PROJECT_ID} TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_ds_local__${PROJECT_ID} TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_local__${PROJECT_ID} TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_ds_local__${PROJECT_ID} TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_drupal_local__${PROJECT_ID} TO homestead_reader;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_local__${PROJECT_ID} TO homestead_reader;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_ds_local__${PROJECT_ID} TO homestead_reader;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_local__${PROJECT_ID} TO homestead_reader;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_ds_local__${PROJECT_ID} TO homestead_reader;
EOSQL