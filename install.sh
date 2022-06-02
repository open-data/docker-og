#!/bin/bash

. docker/install/_variables.sh
. docker/install/_functions.sh

if [[ -z ${CONTAINER_ROLE+x} ]]; then

  printf "${EOL}${Yellow}${INDENT}Container role not set, are you running the script inside a docker container? Exiting install script...${NC}${SPACER}"
  exit 1;

fi

#
# Install Drupal
#
function install_drupal {

  . docker/install/install-drupal.sh

}
# END
# Install Drupal
# END

#
# Install CKAN
#
function install_ckan {

  . docker/install/install-ckan.sh

}
# END
# Install CKAN
# END

#
# Install Django
#
function install_django {

  . docker/install/install-django.sh

}
# END
# Install Django
# END

#
# Install Databases
#
function install_databases {

  . docker/install/install-databases.sh

}
# END
# Install Databases
# END

#
# Install Database Copies
#
function install_database_copies {

  . docker/install/install-test-databases.sh

}
# END
# Install Database Copies
# END

printf "${SPACER}${Cyan}${INDENT}Select what to install:${NC}${SPACER}"

if [[ ${CONTAINER_ROLE} == "drupal" ]]; then

  # Options for the user to select from
  options=(
    "Drupal" 
    "Databases (fixes missing databases, privileges, and users)"
    "Test Databases (clones existing databases into empty ones)"
    "All" 
    "Exit"
  )

elif [[ ${CONTAINER_ROLE} == "ckan" ]]; then

  # Options for the user to select from
  options=(
    "CKAN (${CKAN_ROLE})"
    "Databases (fixes missing databases, privileges, and users)"
    "Test Databases (clones existing databases into empty ones)"
    "All" 
    "Exit"
  )

elif [[ ${CONTAINER_ROLE} == "search" ]]; then

  # Options for the user to select from
  options=(
    "Django"
    "Databases (fixes missing databases, privileges, and users)"
    "Test Databases (clones existing databases into empty ones)"
    "All" 
    "Exit"
  )

fi

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

  # "Drupal or CKAN or Django"
  (0) 
    if [[ ${CONTAINER_ROLE} == "drupal" ]]; then
      exitScript='false'
      installDrupal='true'
    elif [[ ${CONTAINER_ROLE} == "ckan" ]]; then
      exitScript='false'
      installCKAN='true'
    elif [[ ${CONTAINER_ROLE} == "search" ]]; then
      exitScript='false'
      installDjango='true'
    fi
    ;;

  # "Databases (fixes missing databases, privileges, and users)"
  (1)
    exitScript='false'
    installDatabases='true'
    ;;

  # "Test Databases (clones existing databases into empty ones)"
  (2)
    exitScript='false'
    installDatabaseCopies='true'
    ;;

  # "All"
  (3) 
    if [[ ${CONTAINER_ROLE} == "drupal" ]]; then
      installDrupal='true'
      installCKAN='false'
      installDjango='false'
    elif [[ ${CONTAINER_ROLE} == "ckan" ]]; then
      installCKAN='true'
      installDjango='false'
      installDrupal='false'
    elif [[ ${CONTAINER_ROLE} == "search" ]]; then
      installDjango='true'
      installCKAN='false'
      installDrupal='false'
    fi
    exitScript='false'
    installDatabases='true'
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

  if [[ $installDatabases == "true" ]]; then

    install_databases

  fi

  if [[ $installDatabaseCopies == "true" ]]; then

    install_database_copies

  fi

  if [[ $installDrupal == "true" ]]; then

    install_drupal

  fi

  if [[ $installCKAN == "true" ]]; then

    install_ckan

  fi

  if [[ $installDjango == "true" ]]; then

    install_django

  fi

else

  printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi
# END
# Run Script
# END