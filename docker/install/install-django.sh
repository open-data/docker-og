#!/bin/bash

printf "${SPACER}${Cyan}${INDENT}Select what to install for ${BOLD}Django:${HAIR}${NC}${SPACER}"

# Options for the user to select from
options=(
  "OC Django Search App (version 2)"
  "Static Files"
  "Searches"
  "Set File Permissions"
  "All"
  "Exit"
)

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

  # "OC Django Search App (version 2)"
  (0)
    exitScript='false'
    installApp_Django='true'
    ;;

  # "Static Files"
  (1)
    exitScript='false'
    installFiles_Django='true'
    ;;

  # "Searches"
  (2)
    exitScript='false'
    installSearches_Django='true'
    ;;

  # "Set File Permissions"
  (3)
    exitScript='false'
    installFilePermissions_Django='true'
    ;;

  # "All"
  (4)
    exitScript='false'
    installApp_Django='true'
    installFiles_Django='true'
    installSearches_Django='true'
    installFilePermissions_Django='true'
    ;;

  # "Exit"
  (5)
    exitScript='true'
    ;;

esac

#
# Run Script
#
if [[ $exitScript != "true" ]]; then

  cd ${APP_ROOT}
  . ${PWD}/docker/install/django/install-confirmation.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/django/install-source.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/django/install-static.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/django/install-searches.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/django/install-perms.sh
  cd ${APP_ROOT}

else

  printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi
