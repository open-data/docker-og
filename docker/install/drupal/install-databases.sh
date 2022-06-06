#!/bin/bash

#
# Destroy and re-import the Drupal database
#
if [[ $installDB_Drupal == "true" ]]; then

    if [[ -f "${APP_ROOT}/backup/drupal_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Local backup file exists, using ${BOLD}${APP_ROOT}/backup/drupal_db.pgdump${PROJECT_ID}${HAIR}${NC}${SPACER}"

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_drupal_local__${PROJECT_ID} DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_drupal_local__${PROJECT_ID} --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_drupal_local__${PROJECT_ID} TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_drupal_local__${PROJECT_ID}${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=$PGDATABASE --username=$PGUSER ${APP_ROOT}/backup/drupal_db.pgdump

    elif  [[ -f "/opt/tbs/docker/backup/drupal_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Global backup file exists, using ${BOLD}/opt/tbs/docker/backup/drupal_db.pgdump${PROJECT_ID}${HAIR}${NC}${SPACER}"

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_drupal_local__${PROJECT_ID} DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_drupal_local__${PROJECT_ID} --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_drupal_local__${PROJECT_ID} TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_drupal_local__${PROJECT_ID}${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=$PGDATABASE --username=$PGUSER /opt/tbs/docker/backup/drupal_db.pgdump

    else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_drupal_local__${PROJECT_ID} DB${HAIR}${Orange} import, no local or global backup found.${NC}${SPACER}"

    fi

fi
# END
# Destroy and re-import the Drupal database
# END