#!/bin/bash

#
# Destroy and re-import the Drupal database
#
if [[ $installDB_Drupal == "true" ]]; then

    printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_drupal_local__${PROJECT_ID} DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
    psql -eb --dbname=og_drupal_local__${PROJECT_ID} --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_drupal_local__${PROJECT_ID} TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

    # import the database
    printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_drupal_local__${PROJECT_ID}${HAIR}${NC}${SPACER}"
    pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=$PGDATABASE --username=$PGUSER ${APP_ROOT}/backup/drupal_db.pgdump

fi
# END
# Destroy and re-import the Drupal database
# END