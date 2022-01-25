#!/bin/bash
set -e

psql -v ON_ERROR_STOP=0 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER homestead;
    ALTER USER homestead PASSWORD 'secret';
    CREATE DATABASE og_drupal_local;
    CREATE DATABASE og_ckan_local;
    CREATE DATABASE og_ckan_registry_local;
    CREATE DATABASE og_ckan_registry_ds_local;
    GRANT ALL PRIVILEGES ON DATABASE og_drupal_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_ds_local TO homestead;
EOSQL