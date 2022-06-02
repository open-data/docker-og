#!/bin/bash

printf "${SPACER}${Cyan}${INDENT}Select what to install for ${BOLD}Django:${HAIR}${NC}${SPACER}"

# Options for the user to select from
options=(
  "OGC Django Search App (version 1)" 
  "Static Files" 
  "Set File Permissions" 
  "All" 
  "Exit"
)

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

  # "OGC Django Search App (version 1)"
  (0) 
    exitScript='false'
    installApp_Django='true'
    ;;

  # "Static Files"
  (1) 
    exitScript='false'
    installFiles_Django='true'
    ;;

  # "Set File Permissions"
  (2)
    exitScript='false'
    installFilePermissions_Django='true'
    ;;

  # "All"
  (3)
    exitScript='false'
    installApp_Django='true'
    installFiles_Django='true'
    installFilePermissions_Django='true'
    ;;

  # "Exit"
  (4)
    exitScript='true'
    ;;

esac

#
# Run Script
#
if [[ $exitScript != "true" ]]; then

  . ${PWD}/docker/install/django/install-confirmation.sh
  . ${PWD}/docker/install/django/install-source.sh
  . ${PWD}/docker/install/django/install-static.sh
  . ${PWD}/docker/install/django/install-perms.sh

else

  printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi