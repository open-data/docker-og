#!/bin/bash

printf "${SPACER}${Cyan}${INDENT}Select the action for ${BOLD}Postgres Upgrade:${HAIR}${NC}${SPACER}"

cd ${APP_ROOT}
mkdir -p backup/psql_upgrade

# Options for the user to select from
options=(
  "Dump all existing databases (do PRIOR to Postgres version upgrade)"
  "Restore all databases (do AFTER Postgres version upgrade)"
  "Exit"
)

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

  # "Dump all existing databases (do PRIOR to Postgres version upgrade)"
  (0)
    exitScript='false'
    dumpDatabases='true'
    restoreDatabases='false'
    ;;

  # "Restore all databases (do AFTER Postgres version upgrade)"
  (1)
    exitScript='false'
    dumpDatabases='false'
    restoreDatabases='true'
    ;;

  # "Exit"
  (3)
    exitScript='true'
    ;;

esac

#
# Run Script
#
if [[ $exitScript != "true" ]]; then

  cd ${APP_ROOT}
  . ${PWD}/docker/install/postgres/dump.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/postgres/restore.sh
  cd ${APP_ROOT}

else

  printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi
# END
# Run Script
# END
