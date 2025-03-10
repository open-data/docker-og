#!/bin/bash

#
# Destroy and re-import registry and portal database
#
if [[ $installDB_CKAN == "true" ]]; then

    if [[ -f "${APP_ROOT}/backup/ckan_registry_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Local backup file exists, using ${BOLD}${APP_ROOT}/backup/ckan_registry_db.pgdump${PROJECT_ID}${HAIR}${NC}${SPACER}"

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_registry_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_registry_local --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_registry_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_registry_local${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_registry_local --username=$PGUSER ${APP_ROOT}/backup/ckan_registry_db.pgdump

    elif  [[ -f "/opt/tbs/docker/backup/ckan_registry_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Global backup file exists, using ${BOLD}/opt/tbs/docker/backup/ckan_registry_db.pgdump${PROJECT_ID}${HAIR}${NC}${SPACER}"

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_registry_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_registry_local --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_registry_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_registry_local${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_registry_local --username=$PGUSER /opt/tbs/docker/backup/ckan_registry_db.pgdump

    else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_registry_local DB${HAIR}${Orange} import, no local or global backup found.${NC}${SPACER}"

    fi

    if [[ -f "${APP_ROOT}/backup/ckan_portal_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Local backup file exists, using ${BOLD}${APP_ROOT}/backup/ckan_portal_db.pgdump${PROJECT_ID}${HAIR}${NC}${SPACER}"

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_portal_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_portal_local --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_portal_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_portal_local${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_portal_local --username=$PGUSER ${APP_ROOT}/backup/ckan_portal_db.pgdump

    elif  [[ -f "/opt/tbs/docker/backup/ckan_portal_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Global backup file exists, using ${BOLD}/opt/tbs/docker/backup/ckan_portal_db.pgdump${PROJECT_ID}${HAIR}${NC}${SPACER}"

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_portal_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_portal_local --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_portal_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_portal_local${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_portal_local --username=$PGUSER /opt/tbs/docker/backup/ckan_portal_db.pgdump

    else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_portal_local DB${HAIR}${Orange} import, no local or global backup found.${NC}${SPACER}"

    fi

fi
# END
# Destroy and re-import registry and portal database
# END

#
# Destroy and re-import registry and portal datastore database
#
if [[ $installDB_DS_CKAN == "true" ]]; then

    if [[ -f "${APP_ROOT}/backup/ckan_registry_ds_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Local backup file exists, using ${BOLD}${APP_ROOT}/backup/ckan_registry_ds_db.pgdump${PROJECT_ID}${HAIR}${NC}${SPACER}"

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_registry_ds_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_registry_ds_local --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_registry_ds_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_registry_ds_local${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_registry_ds_local --username=$PGUSER ${APP_ROOT}/backup/ckan_registry_ds_db.pgdump

    elif  [[ -f "/opt/tbs/docker/backup/ckan_registry_ds_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Global backup file exists, using ${BOLD}/opt/tbs/docker/backup/ckan_registry_ds_db.pgdump${PROJECT_ID}${HAIR}${NC}${SPACER}"

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_registry_ds_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_registry_ds_local --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_registry_ds_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_registry_ds_local${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_registry_ds_local --username=$PGUSER /opt/tbs/docker/backup/ckan_registry_ds_db.pgdump

    else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_registry_ds_local DB${HAIR}${Orange} import, no local or global backup found.${NC}${SPACER}"

    fi

    if [[ -f "${APP_ROOT}/backup/ckan_portal_ds_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Local backup file exists, using ${BOLD}${APP_ROOT}/backup/ckan_portal_ds_db.pgdump${PROJECT_ID}${HAIR}${NC}${SPACER}"

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_portal_ds_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_portal_ds_local --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_portal_ds_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_portal_ds_local${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_portal_ds_local --username=$PGUSER ${APP_ROOT}/backup/ckan_portal_ds_db.pgdump

    elif  [[ -f "/opt/tbs/docker/backup/ckan_portal_ds_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Global backup file exists, using ${BOLD}/opt/tbs/docker/backup/ckan_portal_ds_db.pgdump${PROJECT_ID}${HAIR}${NC}${SPACER}"

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_portal_ds_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_portal_ds_local --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_portal_ds_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_portal_ds_local${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_portal_ds_local --username=$PGUSER /opt/tbs/docker/backup/backup/ckan_portal_ds_db.pgdump

    else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_portal_ds_local DB${HAIR}${Orange} import, no local or global backup found.${NC}${SPACER}"

    fi

fi
# END
# Destroy and re-import registry and portal datastore database
# END
