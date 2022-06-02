#!/bin/bash

#
# Destroy and re-import portal database
#
if [[ $installDB_Portal_CKAN == "true" ]]; then

    if [[ -f "${APP_ROOT}/backup/ckan_portal_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_portal_local__${PROJECT_ID} DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_portal_local__${PROJECT_ID} --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_portal_local__${PROJECT_ID} TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_portal_local__${PROJECT_ID}${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_portal_local__${PROJECT_ID} --username=$PGUSER ${APP_ROOT}/backup/ckan_portal_db.pgdump

    else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_portal_local__${PROJECT_ID} DB${HAIR}${Orange} import, backup/ckan_portal_db.pgdump does not exist.${NC}${SPACER}"

    fi

fi
# END
# Destroy and re-import portal database
# END

#
# Destroy and re-import portal datastore database
#
if [[ $installDB_Portal_DS_CKAN == "true" ]]; then

    if [[ -f "${APP_ROOT}/backup/ckan_portal_ds_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_portal_ds_local__${PROJECT_ID} DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_portal_ds_local__${PROJECT_ID} --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_portal_ds_local__${PROJECT_ID} TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_portal_ds_local__${PROJECT_ID}${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_portal_ds_local__${PROJECT_ID} --username=$PGUSER ${APP_ROOT}/backup/ckan_portal_ds_db.pgdump

    else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_portal_ds_local__${PROJECT_ID} DB${HAIR}${Orange} import, backup/ckan_portal_ds_db.pgdump does not exist.${NC}${SPACER}"

    fi

fi
# END
# Destroy and re-import portal datastore database
# END

#
# Destroy and re-import registry database
#
if [[ $installDB_Registry_CKAN == "true" ]]; then

    if [[ -f "${APP_ROOT}/backup/ckan_registry_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_registry_local__${PROJECT_ID} DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_registry_local__${PROJECT_ID} --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_registry_local__${PROJECT_ID} TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_registry_local__${PROJECT_ID}${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_registry_local__${PROJECT_ID} --username=$PGUSER ${APP_ROOT}/backup/ckan_registry_db.pgdump

    else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_registry_local__${PROJECT_ID} DB${HAIR}${Orange} import, backup/ckan_registry_db.pgdump does not exist.${NC}${SPACER}"

    fi

fi
# END
# Destroy and re-import registry database
# END

#
# Destroy and re-import registry datastore database
#
if [[ $installDB_Registry_DS_CKAN == "true" ]]; then

    if [[ -f "${APP_ROOT}/backup/ckan_registry_ds_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_registry_ds_local__${PROJECT_ID} DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_registry_ds_local__${PROJECT_ID} --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_registry_ds_local__${PROJECT_ID} TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_registry_ds_local__${PROJECT_ID}${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_registry_ds_local__${PROJECT_ID} --username=$PGUSER ${APP_ROOT}/backup/ckan_registry_ds_db.pgdump

    else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_registry_ds_local__${PROJECT_ID} DB${HAIR}${Orange} import, backup/ckan_registry_ds_db.pgdump does not exist.${NC}${SPACER}"

    fi

fi
# END
# Destroy and re-import registry datastore database
# END