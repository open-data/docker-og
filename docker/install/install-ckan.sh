#!/bin/bash

printf "${SPACER}${Cyan}${INDENT}Select what to install for ${BOLD}CKAN:${HAIR}${NC}${SPACER}"

if [[ $CKAN_ROLE == 'registry' ]]; then

  # Options for the user to select from
  options=(
    "Registry Database" 
    "Registry Datastore Database" 
    "Repositories (Installs them into Python venv ckan/${CKAN_ROLE})" 
    "Download Wet-Boew Files" 
    "Set File Permissions" 
    "Create Local User" 
    "Import Organizations" 
    "Import Datasets" 
    "All" 
    "Exit"
  )

elif [[ $CKAN_ROLE == 'portal' ]]; then

  # Options for the user to select from
  options=(
    "Portal Database" 
    "Portal Datastore Database" 
    "Repositories (Installs them into Python venv ckan/${CKAN_ROLE})" 
    "Download Wet-Boew Files" 
    "Set File Permissions" 
    "Create Local User" 
    "Import Organizations" 
    "Import Datasets" 
    "All" 
    "Exit"
  )

fi

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

  # "Registry Database / Portal Database"
  (0) 
    exitScript='false'
    if [[ $CKAN_ROLE == 'registry' ]]; then
      installDB_Registry_CKAN='true'
      installDB_Portal_CKAN='false'
    elif [[ $CKAN_ROLE == 'portal' ]]; then
      installDB_Portal_CKAN='true'
      installDB_Registry_CKAN='false'
    fi
    ;;

  # "Registry Datastore Database / Portal Datastore Database"
  (1) 
    exitScript='false'
    if [[ $CKAN_ROLE == 'registry' ]]; then
      installDB_Registry_DS_CKAN='true'
      installDB_Portal_DS_CKAN='false'
    elif [[ $CKAN_ROLE == 'portal' ]]; then
      installDB_Portal_DS_CKAN='true'
      installDB_Registry_DS_CKAN='false'
    fi
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

  # "All"
  (8) 
    exitScript='false'
    if [[ $CKAN_ROLE == 'registry' ]]; then
      installDB_Registry_CKAN='true'
      installDB_Registry_DS_CKAN='true'
      installDB_Portal_CKAN='false'
      installDB_Portal_DS_CKAN='false'
    elif [[ $CKAN_ROLE == 'portal' ]]; then
      installDB_Portal_CKAN='true'
      installDB_Portal_DS_CKAN='true'
      installDB_Registry_CKAN='false'
      installDB_Registry_DS_CKAN='false'
    fi
    installRepos_CKAN='true'
    installFilePermissions_CKAN='true'
    installLocalUser_CKAN='true'
    installOrgs_CKAN='true'
    installDatasets_CKAN='true'
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

  . ${PWD}/docker/install/ckan/install-confirmation.sh
  . ${PWD}/docker/install/ckan/install-databases.sh
  . ${PWD}/docker/install/ckan/install-source.sh
  . ${PWD}/docker/install/ckan/install-static.sh
  . ${PWD}/docker/install/ckan/install-perms.sh
  . ${PWD}/docker/install/ckan/install-user.sh
  . ${PWD}/docker/install/ckan/install-orgs.sh
  . ${PWD}/docker/install/ckan/install-datasets.sh

else

  printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi
# END
# Run Script
# END