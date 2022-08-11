#!/bin/bash

printf "${SPACER}${Cyan}${INDENT}Select what databases you want to clone:${HAIR}${NC}${SPACER}"

# Options for the user to select from
options=(
    "og_drupal_local" 
    "og_ckan_portal_local" 
    "og_ckan_portal_ds_local" 
    "og_ckan_registry_local" 
    "og_ckan_registry_ds_local"
    "All" 
    "Exit"
)

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

    # "og_drupal_local" 
    (0) 
        exitScript='false'
        cloneDB_Drupal='true'
        ;;

    # "og_ckan_portal_local" 
    (1) 
        exitScript='false'
        cloneDB_Portal_CKAN='true'
        ;;

    # "og_ckan_portal_ds_local" 
    (2)
        exitScript='false'
        cloneDB_Portal_DS_CKAN='true'
        ;;

    # "og_ckan_registry_local" 
    (3)
        exitScript='false'
        cloneDB_Registry_CKAN='true'
        ;;

    # "og_ckan_registry_ds_local"
    (4)
        exitScript='false'
        cloneDB_Registry_DS_CKAN='true'
        ;;

    # "All"
    (5) 
        exitScript='false'
        cloneDB_Drupal='true'
        cloneDB_Portal_CKAN='true'
        cloneDB_Portal_DS_CKAN='true'
        cloneDB_Registry_CKAN='true'
        cloneDB_Registry_DS_CKAN='true'
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

    #
    # Confirm Drupal database clone
    #
    if [[ $cloneDB_Drupal == "true" ]]; then

      read -r -p $'\n\n\033[0;31m    Are you sure you want clone the\033[1m existing Drupal database\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

      if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        cloneDB_Drupal='true'

      else

        cloneDB_Drupal='false'

      fi

    fi
    # END
    # Confirm Drupal database clone
    # END

    #
    # Confirm CKAN Portal database clone
    #
    if [[ $cloneDB_Portal_CKAN == "true" ]]; then

      read -r -p $'\n\n\033[0;31m    Are you sure you want clone the\033[1m existing CKAN Portal database\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

      if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        cloneDB_Portal_CKAN='true'

      else

        cloneDB_Portal_CKAN='false'

      fi

    fi
    # END
    # Confirm CKAN Portal database clone
    # END

    #
    # Confirm CKAN Portal Datastore database clone
    #
    if [[ $cloneDB_Portal_DS_CKAN == "true" ]]; then

      read -r -p $'\n\n\033[0;31m    Are you sure you want clone the\033[1m existing CKAN Portal Datastore database\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

      if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        cloneDB_Portal_DS_CKAN='true'

      else

        cloneDB_Portal_DS_CKAN='false'

      fi

    fi
    # END
    # Confirm CKAN Portal Datastore database clone
    # END

    #
    # Confirm CKAN Registry database clone
    #
    if [[ $cloneDB_Registry_CKAN == "true" ]]; then

      read -r -p $'\n\n\033[0;31m    Are you sure you want clone the\033[1m existing CKAN Registry database\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

      if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        cloneDB_Registry_CKAN='true'

      else

        cloneDB_Registry_CKAN='false'

      fi

    fi
    # END
    # Confirm CKAN Registry database clone
    # END

    #
    # Confirm CKAN Registry Datastore database clone
    #
    if [[ $cloneDB_Registry_DS_CKAN == "true" ]]; then

      read -r -p $'\n\n\033[0;31m    Are you sure you want clone the\033[1m existing CKAN Registry Datastore database\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

      if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        cloneDB_Registry_DS_CKAN='true'

      else

        cloneDB_Registry_DS_CKAN='false'

      fi

    fi
    # END
    # Confirm CKAN Registry Datastore database clone
    # END

    #
    # Clone Drupal database
    #
    if [[ $cloneDB_Drupal == "true" ]]; then

      psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
        CREATE DATABASE og_drupal_local__test WITH TEMPLATE og_drupal_local;
        GRANT ALL PRIVILEGES ON DATABASE og_drupal_local__test TO homestead;
        GRANT ALL PRIVILEGES ON DATABASE og_drupal_local__test TO homestead_reader;
EOSQL

    fi
    # END
    # Clone Drupal database
    # END

    #
    # Clone CKAN Portal database
    #
    if [[ $cloneDB_Portal_CKAN == "true" ]]; then

      psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
        CREATE DATABASE og_ckan_portal_local__test WITH TEMPLATE og_ckan_portal_local;
        GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_local__test TO homestead;
        GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_local__test TO homestead_reader;
EOSQL

    fi
    # END
    # Clone CKAN Portal database
    # END

    #
    # Clone CKAN Portal Datastore database
    #
    if [[ $cloneDB_Portal_DS_CKAN == "true" ]]; then

      psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
        CREATE DATABASE og_ckan_portal_ds_local__test WITH TEMPLATE og_ckan_portal_ds_local;
        GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_ds_local__test TO homestead;
        GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_ds_local__test TO homestead_reader;
EOSQL

    fi
    # END
    # Clone CKAN Portal Datastore database
    # END

    #
    # Clone CKAN Registry database
    #
    if [[ $cloneDB_Registry_CKAN == "true" ]]; then

      psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
        CREATE DATABASE og_ckan_registry_local__test WITH TEMPLATE og_ckan_registry_local;
        GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_local__test TO homestead;
        GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_local__test TO homestead_reader;
EOSQL

    fi
    # END
    # Clone CKAN Registry database
    # END

    #
    # Clone CKAN Registry Datastore database
    #
    if [[ $cloneDB_Registry_DS_CKAN == "true" ]]; then

      psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
        CREATE DATABASE og_ckan_registry_ds_local__test WITH TEMPLATE og_ckan_registry_ds_local;
        GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_ds_local__test TO homestead;
        GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_ds_local__test TO homestead_reader;
EOSQL

    fi
    # END
    # Clone CKAN Registry Datastore database
    # END

else

    printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi
# END
# Run Script
# END