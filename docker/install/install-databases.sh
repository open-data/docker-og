#!/bin/bash

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