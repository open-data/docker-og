#!/bin/bash

#
# Confirm dump all databases over old ones
#
if [[ $dumpDatabases == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want to dump the\033[1m existing databases\033[0m\033[0;31m over the old dumps at backup/psql_upgrade? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        do_dump_databases='true'

    else

        do_dump_databases='false'

    fi

fi
# END
# Confirm dump all databases over old ones
# END

#
# Dump all databases
#
if [[ $do_dump_databases == "true" ]]; then

    printf "${SPACER}${Cyan}${INDENT}Dumping all databases. This may take a while...${NC}${SPACER}"
    rm -rf ${APP_ROOT}/backup/psql_upgrade/*.sql

    pg_dumpall -v -U homestead > ${APP_ROOT}/backup/psql_upgrade/all_databases.sql

    printf "${SPACER}${Cyan}${INDENT}DONE!${NC}${SPACER}"

fi
# END
# Dump all databases
# END
