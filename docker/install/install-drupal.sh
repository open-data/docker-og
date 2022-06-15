#!/bin/bash

printf "${SPACER}${Cyan}${INDENT}Select what to install for ${BOLD}Drupal:${HAIR}${NC}${SPACER}"

# Options for the user to select from
options=(
  "Database" 
  "Repositories" 
  "Local Files" 
  "Set File Permissions (also creates missing directories)" 
  "Create Local User"
  "All" 
  "Exit"
)

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

  # "Database"
  (0) 
    exitScript='false'
    installDB_Drupal='true'
    ;;

  # "Repositories"
  (1) 
    exitScript='false'
    installRepos_Drupal='true'
    ;;

  # "Local Files"
  (2)
    exitScript='false'
    installFiles_Drupal='true'
    ;;

  # "Set File Permissions (also creates missing directories)"
  (3)
    exitScript='false'
    installFilePermissions_Drupal='true'
    ;;

  # "Create Local User"
  (4)
    exitScript='false'
    installLocalUser_Drupal='true'
    ;;

  # "All"
  (5) 
    exitScript='false'
    installDB_Drupal='true'
    installRepos_Drupal='true'
    installFiles_Drupal='true'
    installFilePermissions_Drupal='true'
    installLocalUser_Drupal='true'
    ;;

  # "Exit"
  (6)
    exitScript='true'
    ;;

esac

#
# Run Script
#
if [[ $exitScript != "true" ]]; then

  cd ${APP_ROOT}
  . ${PWD}/docker/install/drupal/install-confirmation.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/drupal/install-databases.sh
  cd ${APP_ROOT} 
  . ${PWD}/docker/install/drupal/install-source.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/drupal/install-files.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/drupal/install-perms.sh
  cd ${APP_ROOT}
  . ${PWD}/docker/install/drupal/install-user.sh
  cd ${APP_ROOT}

  #
  # Update Drupal DB and clear Drupal cache
  #
  if [[ -x "$(command -v drush)" ]]; then

    printf "${SPACER}${Cyan}${INDENT}Perform database updates${NC}${SPACER}"
    drush updb --yes

    printf "${SPACER}${Cyan}${INDENT}Clear Drupal caches${NC}${SPACER}"
    drush cr

  fi
  # END
  # Update Drupal DB and clear Drupal cache
  # END

else

  printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi
# END
# Run Script
# END