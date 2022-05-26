#!/bin/bash

#
# Variables
#

# text
Cyan='\033[0;36m'
Yellow='\033[1;33m'
Red='\033[0;31m'
Orange='\033[0;33m'
Green='\033[0;32m'
NC='\033[0;0m'
EOL='\n'
SPACER='\n\n'
INDENT='    '
BOLD='\033[1m'
HAIR='\033[0m'
PWD=$(pwd)

projectID='base'
maintainLocalConfigs='false'
noInteraction='false'

function run_pre_build {

    if [[ $noInteraction == 'false' ]]; then

        printf "${SPACER}"

        # check to maintain local settings files
        if [[ -f "${PWD}/.docker.env" || -f "${PWD}/drupal-local-settings.php" || -f "${PWD}/drupal-services.yml" || -f "${PWD}/portal.ini" || -f "${PWD}/registry.ini" || -f "${PWD}/.env" || -f "${PWD}/search-settings.py" ]]; then

            read -r -p $'\n\n\033[0;31m    Do you wish to maintain your local configuration files? (if No, backups will still be kept once in the backup/local_configs directory) [y/N]:\033[0;0m    ' response

            if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

                maintainLocalConfigs='true'

            else

                maintainLocalConfigs='false'

            fi

        fi

        printf "${SPACER}"

    fi

    if [[ $noInteraction == "false" ]]; then

        # create basic network if it does not exist
        docker network inspect og-local-network >/dev/null 2>&1 || docker network create og-local-network | sed 's/^/        /g'

        # create local network if it does not exist
        docker network inspect og-local-network--$projectID >/dev/null 2>&1 || docker network create og-local-network--$projectID | sed 's/^/        /g'

    else

        # create basic network if it does not exist
        docker network inspect og-local-network >/dev/null 2>&1 || docker network create og-local-network | sed 's/^/    /g'

        # create local network if it does not exist
        docker network inspect og-local-network--$projectID >/dev/null 2>&1 || docker network create og-local-network--$projectID | sed 's/^/    /g'

    fi

    # creat backup directory
    if [[ ! -d "${PWD}/backup" ]]; then
        mkdir ${PWD}/backup
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLD}${PWD}/backup${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLD}${PWD}/backup${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}backup directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat local config backup sub-directory
    if [[ ! -d "${PWD}/backup/local_configs" ]]; then
        mkdir ${PWD}/backup/local_configs
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLD}${PWD}/backup/local_configs${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLD}${PWD}/backup/local_configs${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${PWD}/backup/local_configs directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat postgres directory
    if [[ ! -d "${PWD}/postgres" ]]; then
        mkdir ${PWD}/postgres
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLD}${PWD}/postgres${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLD}${PWD}/postgres${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${PWD}/postgres directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat solr directory
    if [[ ! -d "${PWD}/solr" ]]; then
        mkdir ${PWD}/solr
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLD}${PWD}/solr${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLD}${PWD}/solr${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${PWD}/solr directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat redis directory
    if [[ ! -d "${PWD}/redis" ]]; then
        mkdir ${PWD}/redis
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLD}${PWD}/redis${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLD}${PWD}/redis${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${PWD}/redis directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat nginx directory
    if [[ ! -d "${PWD}/nginx" ]]; then
        mkdir ${PWD}/nginx
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLD}${PWD}/nginx${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLD}${PWD}/nginx${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${PWD}/nginx directory already exists: SKIPPING${NC}${EOL}"
    fi

    # copy .docker.env.example to .docker.env
    if [[ -f "${PWD}/.docker.env" ]]; then
        cp ${PWD}/.docker.env ${PWD}/backup/local_configs/.docker.env
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp ${PWD}/.docker.env.example ${PWD}/.docker.env
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Copy ${BOLD}${PWD}/.docker.env.example${HAIR}${Green} to ${BOLD}${PWD}/.docker.env${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Copy ${BOLD}${PWD}/.docker.env.example${HAIR}${Red} to ${BOLD}${PWD}/.docker.env${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Copy ${PWD}/.docker.env.example to ${PWD}/.docker.env (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy example-drupal-local-settings.php to drupal-local-settings.php
    if [[ -f "${PWD}/drupal-local-settings.php" ]]; then
        cp ${PWD}/drupal-local-settings.php ${PWD}/backup/local_configs/drupal-local-settings.php
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp ${PWD}/example-drupal-local-settings.php ${PWD}/drupal-local-settings.php
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Copy ${BOLD}${PWD}/example-drupal-local-settings.php${HAIR}${Green} to ${BOLD}${PWD}/drupal-local-settings.php${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Copy ${BOLD}${PWD}/example-drupal-local-settings.php${HAIR}${Red} to ${BOLD}${PWD}/drupal-local-settings.php${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Copy ${PWD}/example-drupal-local-settings.php to ${PWD}/drupal-local-settings.php (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy example-drupal-services.yml to drupal-services.yml
    if [[ -f "${PWD}/drupal-services.yml" ]]; then
        cp ${PWD}/drupal-services.yml ${PWD}/backup/local_configs/drupal-services.yml
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp ${PWD}/example-drupal-services.yml ${PWD}/drupal-services.yml
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Copy ${BOLD}${PWD}/example-drupal-services.yml${HAIR}${Green} to ${BOLD}${PWD}/drupal-services.yml${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Copy ${BOLD}${PWD}/example-drupal-services.yml${HAIR}${Red} to ${BOLD}${PWD}/drupal-services.yml${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Copy ${PWD}/example-drupal-services.yml to ${PWD}/drupal-services.yml (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy example-portal.ini to portal.ini
    if [[ -f "${PWD}/portal.ini" ]]; then
        cp ${PWD}/portal.ini ${PWD}/backup/local_configs/portal.ini
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp ${PWD}/example-portal.ini ${PWD}/portal.ini
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Copy ${BOLD}${PWD}/example-portal.ini${HAIR}${Green} to ${BOLD}${PWD}/portal.ini${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Copy ${BOLD}${PWD}/example-portal.ini${HAIR}${Red} to ${BOLD}${PWD}/portal.ini${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Copy ${PWD}/example-portal.ini to ${PWD}/portal.ini (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy example-registry.ini to registry.ini
    if [[ -f "${PWD}/registry.ini" ]]; then
        cp ${PWD}/registry.ini ${PWD}/backup/local_configs/registry.ini
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp ${PWD}/example-registry.ini ${PWD}/registry.ini
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Copy ${BOLD}${PWD}/example-registry.ini${HAIR}${Green} to ${BOLD}${PWD}/registry.ini${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Copy ${BOLD}${PWD}/example-registry.ini${HAIR}${Red} to ${BOLD}${PWD}/registry.ini${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Copy ${PWD}/example-registry.ini to ${PWD}/registry.ini (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy example-search-settings.py to search-settings.py
    if [[ -f "${PWD}/search-settings.py" ]]; then
        cp ${PWD}/search-settings.py ${PWD}/backup/local_configs/search-settings.py
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp ${PWD}/example-search-settings.py ${PWD}/search-settings.py
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Copy ${BOLD}${PWD}/example-search-settings.py${HAIR}${Green} to ${BOLD}${PWD}/search-settings.py${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Copy ${BOLD}${PWD}/example-search-settings.py${HAIR}${Red} to ${BOLD}${PWD}/search-settings.py${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Copy ${PWD}/example-search-settings.py to ${PWD}/search-settings.py (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # create project environment file
    if [[ -f "${PWD}/.env" ]]; then
        cp ${PWD}/.env ${PWD}/backup/local_configs/.env
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        touch ${PWD}/.env && echo "PROJECT_ID=$projectID"$'\r' > ${PWD}/.env
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLD}${PWD}/.env${HAIR}${Green} file with Project ID of ${BOLD}$projectID${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLD}${PWD}/.env${HAIR}${Green} file with Project ID of ${BOLD}$projectID${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Create ${BOLD}${PWD}/.env${HAIR}${Green} file with Project ID of $projectID (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    printf "${EOL}${Green}${INDENT}${BOLD}DONE PRE-BUILD!${HAIR}${NC}${SPACER}"

}

if [[ $1 ]]; then

    if [[ $2 && $2 == "no-interaction" ]]; then

        noInteraction='true'

    fi

    if [[ $noInteraction == "false" ]]; then

        INDENT=$INDENT$INDENT

        read -r -p $'\n\n\033[0;31m    Are you sure you want to run the\033[1m pre build script?\033[0m\033[0;31m [y/N]:\033[0;0m    ' response

        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

            projectID=$1
            run_pre_build

        else

            printf "${SPACER}${Yellow}${INDENT}Exiting pre build script...${NC}${SPACER}"

        fi

    else

        if [[ $3 ]]; then

            PWD=$3

        fi

        INDENT=$INDENT
        projectID=$1
        run_pre_build

    fi

else

    printf "${SPACER}${Yellow}${INDENT}No Project ID supplied. Please provide a Project ID such as: ./pre-build.sh local${NC}${SPACER}"

fi