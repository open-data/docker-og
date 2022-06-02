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
BOLDGREEN='\033[1m'
BOLDRED='\033[1m'
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
        if [[ -f "${PWD}/_config/docker/.docker.env" || -f "${PWD}/_config/drupal/settings.php" || -f "${PWD}/_config/drupal/services.yml" || -f "${PWD}/_config/ckan/portal.ini" || -f "${PWD}/_config/ckan/registry.ini" || -f "${PWD}/.env" || -f "${PWD}/_config/django/settings.py" || -f "${PWD}/docker/config/nginx/conf/.env.conf" ]]; then

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
            printf "${Green}${INDENT}Create ${BOLDGREEN}${PWD}/backup${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLDRED}${PWD}/backup${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}backup directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat local config backup sub-directory
    if [[ ! -d "${PWD}/backup/local_configs" ]]; then
        mkdir ${PWD}/backup/local_configs
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLDGREEN}${PWD}/backup/local_configs${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLDRED}${PWD}/backup/local_configs${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${PWD}/backup/local_configs directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat postgres directory
    if [[ ! -d "${PWD}/postgres" ]]; then
        mkdir ${PWD}/postgres
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLDGREEN}${PWD}/postgres${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLDRED}${PWD}/postgres${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${PWD}/postgres directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat solr directory
    if [[ ! -d "${PWD}/solr" ]]; then
        mkdir ${PWD}/solr
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLDGREEN}${PWD}/solr${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLDRED}${PWD}/solr${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${PWD}/solr directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat redis directory
    if [[ ! -d "${PWD}/redis" ]]; then
        mkdir ${PWD}/redis
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLDGREEN}${PWD}/redis${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLDRED}${PWD}/redis${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${PWD}/redis directory already exists: SKIPPING${NC}${EOL}"
    fi

    # creat nginx directory
    if [[ ! -d "${PWD}/nginx" ]]; then
        mkdir ${PWD}/nginx
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLDGREEN}${PWD}/nginx${HAIR}${Green} directory: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLDRED}${PWD}/nginx${HAIR}${Red} directory: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}${PWD}/nginx directory already exists: SKIPPING${NC}${EOL}"
    fi

    # copy .docker.env example to .docker.env
    if [[ -f "${PWD}/_config/docker/.docker.env" ]]; then
        cp ${PWD}/_config/docker/.docker.env ${PWD}/backup/local_configs/.docker.env
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp ${PWD}/_config_examples/docker/.docker.env ${PWD}/_config/docker/.docker.env
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Copy ${BOLDGREEN}${PWD}/_config_examples/docker/.docker.env${HAIR}${Green} to ${BOLDGREEN}${PWD}/_config/docker/.docker.env${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Copy ${BOLDRED}${PWD}/_config_examples/docker/.docker.env${HAIR}${Red} to ${BOLDRED}${PWD}/_config/docker/.docker.env${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Copy ${PWD}/_config_examples/docker/.docker.env to ${PWD}/_config/docker/.docker.env (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy settings.php example to settings.php
    if [[ -f "${PWD}/_config/drupal/settings.php" ]]; then
        cp ${PWD}/_config/drupal/settings.php ${PWD}/backup/local_configs/settings.php
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp ${PWD}/_config_examples/drupal/settings.php ${PWD}/_config/drupal/settings.php
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Copy ${BOLDGREEN}${PWD}/_config_examples/drupal/settings.php${HAIR}${Green} to ${BOLDGREEN}${PWD}/_config/drupal/settings.php${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Copy ${BOLDRED}${PWD}/_config_examples/drupal/settings.php${HAIR}${Red} to ${BOLDRED}${PWD}/_config/drupal/settings.php${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Copy ${PWD}/_config_examples/drupal/settings.php to ${PWD}/_config/drupal/settings.php (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy services.yml example to services.yml
    if [[ -f "${PWD}/_config/drupal/services.yml" ]]; then
        cp ${PWD}/_config/drupal/services.yml ${PWD}/backup/local_configs/services.yml
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp ${PWD}/_config_examples/drupal/services.yml ${PWD}/_config/drupal/services.yml
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Copy ${BOLDGREEN}${PWD}/_config_examples/drupal/services.yml${HAIR}${Green} to ${BOLDGREEN}${PWD}/_config/drupal/services.yml${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Copy ${BOLDRED}${PWD}/_config_examples/drupal/services.yml${HAIR}${Red} to ${BOLDRED}${PWD}/_config/drupal/services.yml${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Copy ${PWD}/_config_examples/drupal/services.yml to ${PWD}/_config/drupal/services.yml (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy protal.ini example to portal.ini
    if [[ -f "${PWD}/_config/ckan/portal.ini" ]]; then
        cp ${PWD}/_config/ckan/portal.ini ${PWD}/backup/local_configs/portal.ini
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp ${PWD}/_config_examples/ckan/protal.ini ${PWD}/_config/ckan/portal.ini
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Copy ${BOLDGREEN}${PWD}/_config_examples/ckan/protal.ini${HAIR}${Green} to ${BOLDGREEN}${PWD}/_config/ckan/portal.ini${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Copy ${BOLDRED}${PWD}/_config_examples/ckan/protal.ini${HAIR}${Red} to ${BOLDRED}${PWD}/_config/ckan/portal.ini${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Copy ${PWD}/_config_examples/ckan/protal.ini to ${PWD}/_config/ckan/portal.ini (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy registry.ini example to registry.ini
    if [[ -f "${PWD}/_config/ckan/registry.ini" ]]; then
        cp ${PWD}/_config/ckan/registry.ini ${PWD}/backup/local_configs/registry.ini
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp ${PWD}/_config_examples/ckan/registry.ini ${PWD}/_config/ckan/registry.ini
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Copy ${BOLDGREEN}${PWD}/_config_examples/ckan/registry.ini${HAIR}${Green} to ${BOLDGREEN}${PWD}/_config/ckan/registry.ini${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Copy ${BOLDRED}${PWD}/_config_examples/ckan/registry.ini${HAIR}${Red} to ${BOLDRED}${PWD}/_config/ckan/registry.ini${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Copy ${PWD}/_config_examples/ckan/registry.ini to ${PWD}/_config/ckan/registry.ini (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # copy settings.py example to settings.py
    if [[ -f "${PWD}/_config/django/settings.py" ]]; then
        cp ${PWD}/_config/django/settings.py ${PWD}/backup/local_configs/settings.py
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        cp ${PWD}/_config_examples/django/settings.py ${PWD}/_config/django/settings.py
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Copy ${BOLDGREEN}${PWD}/_config_examples/django/settings.py${HAIR}${Green} to ${BOLDGREEN}${PWD}/_config/django/settings.py${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Copy ${BOLDRED}${PWD}/_config_examples/django/settings.py${HAIR}${Red} to ${BOLDRED}${PWD}/_config/django/settings.py${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Copy ${PWD}/_config_examples/django/settings.py to ${PWD}/_config/django/settings.py (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # create project environment file
    if [[ -f "${PWD}/.env" ]]; then
        cp ${PWD}/.env ${PWD}/backup/local_configs/.env
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        touch ${PWD}/.env && echo "PROJECT_ID=$projectID"$'\r' > ${PWD}/.env
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLDGREEN}${PWD}/.env${HAIR}${Green} file with Project ID of ${BOLDGREEN}$projectID${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLDRED}${PWD}/.env${HAIR}${Red} file with Project ID of ${BOLDRED}$projectID${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Create ${PWD}/.env file with Project ID of $projectID (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    # create nginx project environment file
    if [[ -f "${PWD}/docker/config/nginx/conf/.env.conf" ]]; then
        cp ${PWD}/docker/config/nginx/conf/.env.conf ${PWD}/backup/local_configs/.env.conf
    fi
    if [[ $maintainLocalConfigs == "false" ]]; then
        touch ${PWD}/docker/config/nginx/conf/.env.conf && echo "set \$projectID \"$projectID\";"$'\r' > ${PWD}/docker/config/nginx/conf/.env.conf
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}Create ${BOLDGREEN}${PWD}/docker/config/nginx/conf/.env.conf${HAIR}${Green} file with Project ID of ${BOLDGREEN}$projectID${HAIR}${Green}: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}Create ${BOLDRED}${PWD}/docker/config/nginx/conf/.env.conf${HAIR}${Red} file with Project ID of ${BOLDRED}$projectID${HAIR}${Red}: FAIL${NC}${EOL}"
        fi
    else
        printf "${Yellow}${INDENT}Create ${PWD}/docker/config/nginx/conf/.env.conf file with Project ID of $projectID (maintain local settings set to true): SKIPPING${NC}${EOL}"
    fi

    chmod +x ${PWD}/install.sh
    chmod +x ${PWD}/docker/install/*.sh
    chmod +x ${PWD}/docker/install/ckan/*.sh
    chmod +x ${PWD}/docker/install/django/*.sh
    chmod +x ${PWD}/docker/install/drupal/*.sh

    printf "${Green}${INDENT}${BOLDGREEN}DONE PRE-BUILD!${HAIR}${NC}${SPACER}"

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
        BOLDGREEN=${HAIR}${Green}
        BOLDRED=${HAIR}${Red}
        projectID=$1
        run_pre_build

    fi

else

    printf "${SPACER}${Yellow}${INDENT}No Project ID supplied. Please provide a Project ID such as: ./pre-build.sh local${NC}${SPACER}"

fi