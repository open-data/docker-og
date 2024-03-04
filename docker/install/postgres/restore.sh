#!/bin/bash

#
# Confirm restore all databases over old ones
#
if [[ $restoreDatabases == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want to restore the\033[1m old databases\033[0m\033[0;31m over the current databases from backup/psql_upgrade? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        do_restore_databases='true'

    else

        do_restore_databases='false'

    fi

fi
# END
# Confirm restore all databases over old ones
# END

#
# Restore all databases
#
if [[ $do_restore_databases == "true" ]]; then

    printf "${SPACER}${Cyan}${INDENT}Restoring all databases. This may take a while...${NC}${SPACER}"
    if [[ -d "${APP_ROOT}/postgres" ]]; then
      # remove old database data
      rm -rf ${APP_ROOT}/postgres/*
    fi

    cat ${APP_ROOT}/backup/psql_upgrade/all_databases.sql | psql -U homestead

    printf "${SPACER}${Cyan}${INDENT}DONE!${NC}${SPACER}"

fi
# END
# Restore all databases
# END
