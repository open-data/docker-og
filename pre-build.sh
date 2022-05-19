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

projectID='base'
maintainLocalConfigs='false'
noInteraction='false'

function run_pre_build {

    printf "${SPACER}"

    if [[ $noInteraction == 'false' ]]; then

        # check to maintain local settings files
        if [[ -f './.docker.env' || -f './drupal-local-settings.php' || -f './drupal-services.yml' || -f './portal.ini' || -f './registry.ini' || -f './.env' || -f './search-settings.py' || -f './.project.env' ]]; then

            read -r -p $'\n\n\033[0;31m    Do you wish to maintain your local configuration files? (if No, backups will still be kept once in the backup/local_configs directory) [y/N]:\033[0;0m    ' response

            if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

                maintainLocalConfigs='true'

            else

                maintainLocalConfigs='false'

            fi

        fi

        printf "${SPACER}"

    fi

    # create proxy network if it does not exist
    docker network inspect og-proxy-network--$projectID >/dev/null 2>&1 || docker network create og-proxy-network--$projectID

    # create local network if it does not exist
    docker network inspect og-local-network--$projectID >/dev/null 2>&1 || docker network create og-local-network--$projectID

    # creat backup directory
    if [[ ! -d './backup' ]]; then
        mkdir backup
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Create ${BOLD}backup${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Create ${BOLD}backup${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}backup directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat local config backup sub-directory
    if [[ ! -d './backup/local_configs' ]]; then
        mkdir backup/local_configs
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Create ${BOLD}backup/local_configs${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Create ${BOLD}backup/local_configs${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}backup/local_configs directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat postgres directory
    if [[ ! -d './postgres' ]]; then
        mkdir postgres
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Create ${BOLD}postgres${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Create ${BOLD}postgres${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}postgres directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat solr directory
    if [[ ! -d './solr' ]]; then
        mkdir solr
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Create ${BOLD}solr${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Create ${BOLD}solr${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}solr directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat redis directory
    if [[ ! -d './redis' ]]; then
        mkdir redis
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Create ${BOLD}redis${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Create ${BOLD}redis${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}redis directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat nginx directory
    if [[ ! -d './nginx' ]]; then
        mkdir nginx
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Create ${BOLD}nginx${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Create ${BOLD}nginx${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}nginx directory already exists: SKIPPING${NC}${EOL}"
    fi

    # copy .docker.env.example to .docker.env
    if [[ -f './.docker.env' ]]; then
        cp .docker.env backup/local_configs/.docker.env
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp .docker.env.example .docker.env
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Copy ${BOLD}.docker.env.example${HAIR}${Green} to ${BOLD}.docker.env${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Copy ${BOLD}.docker.env.example${HAIR}${Red} to ${BOLD}.docker.env${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}Copy .docker.env.example to .docker.env (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy example-drupal-local-settings.php to drupal-local-settings.php
    if [[ -f './drupal-local-settings.php' ]]; then
        cp drupal-local-settings.php backup/local_configs/drupal-local-settings.php
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp example-drupal-local-settings.php drupal-local-settings.php
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Copy ${BOLD}example-drupal-local-settings.php${HAIR}${Green} to ${BOLD}drupal-local-settings.php${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Copy ${BOLD}example-drupal-local-settings.php${HAIR}${Red} to ${BOLD}drupal-local-settings.php${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}Copy example-drupal-local-settings.php to drupal-local-settings.php (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy example-drupal-services.yml to drupal-services.yml
    if [[ -f './drupal-services.yml' ]]; then
        cp drupal-services.yml backup/local_configs/drupal-services.yml
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp example-drupal-services.yml drupal-services.yml
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Copy ${BOLD}example-drupal-services.yml${HAIR}${Green} to ${BOLD}drupal-services.yml${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Copy ${BOLD}example-drupal-services.yml${HAIR}${Red} to ${BOLD}drupal-services.yml${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}Copy example-drupal-services.yml to drupal-services.yml (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy example-portal.ini to portal.ini
    if [[ -f './portal.ini' ]]; then
        cp portal.ini backup/local_configs/portal.ini
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp example-portal.ini portal.ini
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Copy ${BOLD}example-portal.ini${HAIR}${Green} to ${BOLD}portal.ini${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Copy ${BOLD}example-portal.ini${HAIR}${Red} to ${BOLD}portal.ini${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}Copy example-portal.ini to portal.ini (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy example-registry.ini to registry.ini
    if [[ -f './registry.ini' ]]; then
        cp registry.ini backup/local_configs/registry.ini
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp example-registry.ini registry.ini
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Copy ${BOLD}example-registry.ini${HAIR}${Green} to ${BOLD}registry.ini${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Copy ${BOLD}example-registry.ini${HAIR}${Red} to ${BOLD}registry.ini${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}Copy example-registry.ini to registry.ini (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy .env.example to .env
    if [[ -f './.env' ]]; then
        cp .env backup/local_configs/.env
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp .env.example .env
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Copy ${BOLD}.env.example${HAIR}${Green} to ${BOLD}.env${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Copy ${BOLD}.env.example${HAIR}${Red} to ${BOLD}.env${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}Copy .env.example to .env (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy example-search-settings.py to search-settings.py
    if [[ -f './search-settings.py' ]]; then
        cp search-settings.py backup/local_configs/search-settings.py
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp example-search-settings.py search-settings.py
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Copy ${BOLD}example-search-settings.py${HAIR}${Green} to ${BOLD}search-settings.py${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Copy ${BOLD}example-search-settings.py${HAIR}${Red} to ${BOLD}search-settings.py${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}Copy example-search-settings.py to search-settings.py (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # create project environment file
    if [[ -f './.project.env' ]]; then
        cp .project.env backup/local_configs/.project.env
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        touch .project.env && echo "PROJECT_ID=$projectID"$'\r' > .project.env
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Create .project.env file with Project ID of ${BOLD}$projectID${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Create .project.env file with Project ID of ${BOLD}$projectID${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${INDENT}Create .project.env file with Project ID of $projectID (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    printf "${SPACER}${Green}${INDENT}${BOLD}DONE!${HAIR}${NC}${SPACER}"

}

if [[ $1 ]]; then

    if [[ $2 && $2 == "no-interaction" ]]; then

        noInteraction='true'

    fi

    if [[ $noInteraction == "false" ]]; then

        read -r -p $'\n\n\033[0;31m    Are you sure you want to run the\033[1m pre build script?\033[0m\033[0;31m [y/N]:\033[0;0m    ' response

        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

            projectID=$1
            run_pre_build

        else

            printf "${SPACER}${Yellow}${INDENT}Exiting pre build script...${NC}${SPACER}"

        fi

    else

        projectID=$1
        run_pre_build

    fi

else

    printf "${SPACER}${Yellow}${INDENT}No Project ID supplied. Please provide a Project ID such as: ./pre-build.sh local${NC}${SPACER}"

fi