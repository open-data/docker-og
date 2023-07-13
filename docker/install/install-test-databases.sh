#!/bin/bash

function do_clone_databases {

    printf "${SPACER}${Cyan}${INDENT}Select what databases you want to clone:${HAIR}${NC}${SPACER}"

    # Options for the user to select from
    options=(
        "og_drupal_local"
        "og_drupal_blog_local"
        "og_drupal_guides_local"
        "og_ckan_portal_local"
        "og_ckan_portal_ds_local"
        "og_ckan_registry_local"
        "og_ckan_registry_ds_local"
        "og_search_local"
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

        # "og_drupal_blog_local"
        (1)
            exitScript='false'
            cloneDB_Drupal_Blog='true'
            ;;

        # "og_drupal_guides_local"
        (2)
            exitScript='false'
            cloneDB_Drupal_Guides='true'
            ;;

        # "og_ckan_portal_local"
        (3)
            exitScript='false'
            cloneDB_Portal_CKAN='true'
            ;;

        # "og_ckan_portal_ds_local"
        (4)
            exitScript='false'
            cloneDB_Portal_DS_CKAN='true'
            ;;

        # "og_ckan_registry_local"
        (5)
            exitScript='false'
            cloneDB_Registry_CKAN='true'
            ;;

        # "og_ckan_registry_ds_local"
        (6)
            exitScript='false'
            cloneDB_Registry_DS_CKAN='true'
            ;;

        # "og_search_local"
        (7)
            exitScript='false'
            cloneDB_Search_DJANGO='true'
            ;;

        # "All"
        (8)
            exitScript='false'
            cloneDB_Drupal='true'
            cloneDB_Drupal_Blog='true'
            cloneDB_Drupal_Guides='true'
            cloneDB_Portal_CKAN='true'
            cloneDB_Portal_DS_CKAN='true'
            cloneDB_Registry_CKAN='true'
            cloneDB_Registry_DS_CKAN='true'
            cloneDB_Search_DJANGO='true'
            ;;

        # "Exit"
        (9)
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
        # Confirm Drupal Blog database clone
        #
        if [[ $cloneDB_Drupal_Blog == "true" ]]; then

          read -r -p $'\n\n\033[0;31m    Are you sure you want clone the\033[1m existing Drupal Blog database\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

          if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

            cloneDB_Drupal_Blog='true'

          else

            cloneDB_Drupal_Blog='false'

          fi

        fi
        # END
        # Confirm Drupal Guides database clone
        # END

        #
        # Confirm Drupal Blog database clone
        #
        if [[ $cloneDB_Drupal_Guides == "true" ]]; then

          read -r -p $'\n\n\033[0;31m    Are you sure you want clone the\033[1m existing Drupal Guides database\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

          if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

            cloneDB_Drupal_Guides='true'

          else

            cloneDB_Drupal_Guides='false'

          fi

        fi
        # END
        # Confirm Drupal Guides database clone
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
        # Confirm DJANGO Searcj database clone
        #
        if [[ $cloneDB_Search_DJANGO == "true" ]]; then

          read -r -p $'\n\n\033[0;31m    Are you sure you want clone the\033[1m existing DJANGO Search database\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

          if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

            cloneDB_Search_DJANGO='true'

          else

            cloneDB_Search_DJANGO='false'

          fi

        fi

        # END
        # Confirm DJANGO Searcj database clone
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
        # Clone Drupal Blog database
        #
        if [[ $cloneDB_Drupal_Blog == "true" ]]; then

          psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
            CREATE DATABASE og_drupal_blog_local__test WITH TEMPLATE og_drupal_blog_local;
            GRANT ALL PRIVILEGES ON DATABASE og_drupal_blog_local__test TO homestead;
            GRANT ALL PRIVILEGES ON DATABASE og_drupal_blog_local__test TO homestead_reader;
EOSQL

        fi
        # END
        # Clone Drupal Blog database
        # END

        #
        # Clone Drupal Guides database
        #
        if [[ $cloneDB_Drupal_Guides == "true" ]]; then

          psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
            CREATE DATABASE og_drupal_guides_local__test WITH TEMPLATE og_drupal_guides_local;
            GRANT ALL PRIVILEGES ON DATABASE og_drupal_guides_local__test TO homestead;
            GRANT ALL PRIVILEGES ON DATABASE og_drupal_guides_local__test TO homestead_reader;
EOSQL

        fi
        # END
        # Clone Drupal Guides database
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

        #
        # Clone DJANGO Search database
        #
        if [[ $cloneDB_Search_DJANGO == "true" ]]; then

          psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
            CREATE DATABASE og_search_local__test WITH TEMPLATE og_search_local;
            GRANT ALL PRIVILEGES ON DATABASE og_search_local__test TO homestead;
            GRANT ALL PRIVILEGES ON DATABASE og_search_local__test TO homestead_reader;
EOSQL

        fi
        # END
        # Clone DJANGO Search database
        # END

    else

        printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

    fi
    # END
    # Run Script
    # END

}

function do_create_blank_databases {

    printf "${SPACER}${Cyan}${INDENT}Select what blank databases you want to create:${HAIR}${NC}${SPACER}"

    # Options for the user to select from
    options=(
        "og_drupal_local__test"
        "og_drupal_blog_local__test"
        "og_drupal_guides_local__test"
        "og_ckan_portal_local__test"
        "og_ckan_portal_ds_local__test"
        "og_ckan_registry_local__test"
        "og_ckan_registry_ds_local__test"
        "og_search_local__test"
        "All"
        "Exit"
    )

    # IMPORTANT: select_option will return the index of the options and not the value.
    select_option "${options[@]}"
    opt=$?

    case $opt in

        # "og_drupal_local__test"
        (0)
            exitScript='false'
            create_Test_DB_Drupal='true'
            ;;

        # "og_drupal_blog_local__test"
        (1)
            exitScript='false'
            create_Test_DB_Drupal_Blog='true'
            ;;

        # "og_drupal_guides_local__test"
        (2)
            exitScript='false'
            create_Test_DB_Drupal_Guides='true'
            ;;

        # "og_ckan_portal_local__test"
        (3)
            exitScript='false'
            create_Test_DB_Portal_CKAN='true'
            ;;

        # "og_ckan_portal_ds_local__test"
        (4)
            exitScript='false'
            create_Test_DB_Portal_DS_CKAN='true'
            ;;

        # "og_ckan_registry_local__test"
        (5)
            exitScript='false'
            create_Test_DB_Registry_CKAN='true'
            ;;

        # "og_ckan_registry_ds_local__test"
        (6)
            exitScript='false'
            create_Test_DB_Registry_DS_CKAN='true'
            ;;

        # "og_search_local__test"
        (7)
            exitScript='false'
            create_Test_DB_Search_DJANGO='true'
            ;;

        # "All"
        (8)
            exitScript='false'
            create_Test_DB_Drupal='true'
            create_Test_DB_Drupal_Blog='true'
            create_Test_DB_Drupal_Guides='true'
            create_Test_DB_Portal_CKAN='true'
            create_Test_DB_Portal_DS_CKAN='true'
            create_Test_DB_Registry_CKAN='true'
            create_Test_DB_Registry_DS_CKAN='true'
            create_Test_DB_Search_DJANGO='true'
            ;;

        # "Exit"
        (9)
            exitScript='true'
            ;;

    esac

    #
    # Run Script
    #
    if [[ $exitScript != "true" ]]; then

        #
        # Create blank Drupal database
        #
        if [[ $create_Test_DB_Drupal == "true" ]]; then

          psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
            CREATE DATABASE og_drupal_local__test;
            GRANT ALL PRIVILEGES ON DATABASE og_drupal_local__test TO homestead;
            GRANT ALL PRIVILEGES ON DATABASE og_drupal_local__test TO homestead_reader;
EOSQL

        fi
        # END
        # Create blank Drupal database
        # END

        #
        # Create blank Drupal Blog database
        #
        if [[ $create_Test_DB_Drupal_Blog == "true" ]]; then

          psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
            CREATE DATABASE og_drupal_blog_local__test;
            GRANT ALL PRIVILEGES ON DATABASE og_drupal_blog_local__test TO homestead;
            GRANT ALL PRIVILEGES ON DATABASE og_drupal_blog_local__test TO homestead_reader;
EOSQL

        fi
        # END
        # Create blank Drupal Blog database
        # END

        #
        # Create blank Drupal Guides database
        #
        if [[ $create_Test_DB_Drupal_Guides == "true" ]]; then

          psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
            CREATE DATABASE og_drupal_guides_local__test;
            GRANT ALL PRIVILEGES ON DATABASE og_drupal_guides_local__test TO homestead;
            GRANT ALL PRIVILEGES ON DATABASE og_drupal_guides_local__test TO homestead_reader;
EOSQL

        fi
        # END
        # Create blank Drupal Guides database
        # END

        #
        # Create blank CKAN Portal database
        #
        if [[ $create_Test_DB_Portal_CKAN == "true" ]]; then

          psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
            CREATE DATABASE og_ckan_portal_local__test;
            GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_local__test TO homestead;
            GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_local__test TO homestead_reader;
EOSQL

        fi
        # END
        # Create blank CKAN Portal database
        # END

        #
        # Create blank CKAN Portal Datastore database
        #
        if [[ $create_Test_DB_Portal_DS_CKAN == "true" ]]; then

          psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
            CREATE DATABASE og_ckan_portal_ds_local__test;
            GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_ds_local__test TO homestead;
            GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_ds_local__test TO homestead_reader;
EOSQL

        fi
        # END
        # Create blank CKAN Portal Datastore database
        # END

        #
        # Create blank CKAN Registry database
        #
        if [[ $create_Test_DB_Registry_CKAN == "true" ]]; then

          psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
            CREATE DATABASE og_ckan_registry_local__test;
            GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_local__test TO homestead;
            GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_local__test TO homestead_reader;
EOSQL

        fi
        # END
        # Create blank CKAN Registry database
        # END

        #
        # Create blank CKAN Registry Datastore database
        #
        if [[ $create_Test_DB_Registry_DS_CKAN == "true" ]]; then

          psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
            CREATE DATABASE og_ckan_registry_ds_local__test;
            GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_ds_local__test TO homestead;
            GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_ds_local__test TO homestead_reader;
EOSQL

        fi
        # END
        # Create blank CKAN Registry Datastore database
        # END

        #
        # Create blank DJANGO Search database
        #
        if [[ $create_Test_DB_Search_DJANGO == "true" ]]; then

          psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
            CREATE DATABASE og_search_local__test;
            GRANT ALL PRIVILEGES ON DATABASE og_search_local__test TO homestead;
            GRANT ALL PRIVILEGES ON DATABASE og_search_local__test TO homestead_reader;
EOSQL

        fi
        # END
        # Create blank DJANGO Search database
        # END

    else

      printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

    fi
    # END
    # Run Script
    # END

}

printf "${SPACER}${Cyan}${INDENT}Select what you want to do:${NC}${SPACER}"

# Options for the user to select from
options=(
    "Clone existing databases"
    "Create blank test databases"
    "Exit"
)

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in
    # "Clone existing databases"
    (0)
        exitScript='false'
        cloneDatabases='true'
        createBlankDatabases='false'
        ;;

    # "Create blank test databases"
    (1)
        exitScript='false'
        createBlankDatabases='true'
        loneDatabases='false'
        ;;

    # "Exit"
    (2)
        exitScript='true'
        ;;

esac

#
# Run Script
#
if [[ $exitScript != "true" ]]; then

    if [[ $cloneDatabases == "true" ]]; then

      do_clone_databases

    elif [[ $createBlankDatabases == "true" ]]; then

      do_create_blank_databases

    fi

else

    printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi
