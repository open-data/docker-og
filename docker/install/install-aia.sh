#!/bin/bash

printf "${SPACER}${Cyan}${INDENT}Select what to install for ${BOLD}CKAN:${HAIR}${NC}${SPACER}"

# Options for the user to select from
options=(
  "Repositories (Installs them into Node env)"
  "Set File Permissions"
  "All"
  "Exit"
)

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

  # "Repositories (Installs them into Node env)"
  (0)
    exitScript='false'
    installRepos_AIA='true'
    ;;

  # "Set File Permissions"
  (1)
    exitScript='false'
    installFilePermissions_AIA='true'
    ;;

  # "All"
  (2)
    exitScript='false'
    installRepos_AIA='true'
    installFilePermissions_AIA='true'
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
  . ${PWD}/docker/install/aia/install-confirmation.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/aia/install-source.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/aia/install-perms.sh
  cd ${APP_ROOT}

else

  printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi
# END
# Run Script
# END
