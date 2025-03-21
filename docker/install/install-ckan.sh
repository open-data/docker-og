#!/bin/bash

printf "${SPACER}${Cyan}${INDENT}Select what to install for ${BOLD}CKAN:${HAIR}${NC}${SPACER}"

# Options for the user to select from
options=(
  "Registry & Portal Databases"
  "Registry & Portal Datastore Databases"
  "Repositories (Installs them into Python venv ckan)"
  "Download Wet-Boew Files"
  "Set File Permissions"
  "Create Local User"
  "Import Organizations"
  "Import Datasets"
  "Build Inventory Index"
  "All"
  "Exit"
)

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

  # "Registry Database / Portal Database"
  (0)
    exitScript='false'
    installDB_CKAN='true'
    ;;

  # "Registry Datastore Database / Portal Datastore Database"
  (1)
    exitScript='false'
    installDB_DS_CKAN='true'
    ;;

  # "Repositories (Installs them into Python venv)"
  (2)
    exitScript='false'
    installRepos_CKAN='true'
    ;;

  # "Download Wet-Boew Files"
  (3)
    exitScript='false'
    installTheme_CKAN='true'
    ;;


  # "Set File Permissions"
  (4)
    exitScript='false'
    installFilePermissions_CKAN='true'
    ;;

  # "Create Local User"
  (5)
    exitScript='false'
    installLocalUser_CKAN='true'
    ;;

  # "Import Organizations"
  (6)
    exitScript='false'
    installOrgs_CKAN='true'
    ;;

  # "Import Datasets"
  (7)
    exitScript='false'
    installDatasets_CKAN='true'
    ;;

  # "Build Inventory Index"
  (8)
    exitScript='false'
    installInventory_CKAN='true'
    ;;

  # "All"
  (9)
    exitScript='false'
    installDB_CKAN='true'
    installDB_DS_CKAN='true'
    installRepos_CKAN='true'
    installFilePermissions_CKAN='true'
    installLocalUser_CKAN='true'
    installOrgs_CKAN='true'
    installDatasets_CKAN='true'
    installInventory_CKAN='true'
    ;;

  # "Exit"
  (10)
    exitScript='true'
    ;;

esac

#
# Run Script
#
if [[ $exitScript != "true" ]]; then

  cd ${APP_ROOT}
  . ${PWD}/docker/install/ckan/install-confirmation.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/ckan/install-databases.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/ckan/install-source.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/ckan/install-static.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/ckan/install-perms.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/ckan/install-user.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/ckan/install-orgs.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/ckan/install-datasets.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/ckan/install-inventory.sh
  cd ${APP_ROOT}

else

  printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi
# END
# Run Script
# END
