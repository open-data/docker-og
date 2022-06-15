#!/bin/bash

#
# Install OGC Django App
#
if [[ $installApp_Django == "true" ]]; then

    mkdir -p ${APP_ROOT}/django

    # nuke the entire folder
    printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing Django install${NC}${SPACER}"
    # destroy all files
    cd ${APP_ROOT}/django
    rm -rf ./*
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all files in django: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Remove all files in django: FAIL${NC}${EOL}"
    fi
    cd ${APP_ROOT}/django
    rm -rf ./.??*
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all hidden files in django: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Remove all hidden files in django: FAIL${NC}${EOL}"
    fi

    # create virtual environment
    python3 -m venv ${APP_ROOT}/django
    cd ${APP_ROOT}/django

    # set ownership
    chown django:django -R ${APP_ROOT}/django
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set django ownership to django:django: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set django ownership to django:django: FAIL${NC}${EOL}"
    fi

    # activate python environment
    . ${APP_ROOT}/django/bin/activate
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Activate Python environment: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Activate Python environment: FAIL${NC}${EOL}"
    fi

    # install setup tools
    pip install --upgrade setuptools
    pip install --upgrade setuptools_rust
    pip install --upgrade rust
    # install wheel
    pip install wheel
    # install py solr
    pip install pysolr
    # update certifi
    pip install --upgrade certifi
    # install correct version of cryptography
    pip install cryptography==2.2.2

    # install ogc search into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}OGC Search repository${HAIR}${Cyan} from https://github.com:open-data/ogc_search.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ogc_search.git#egg=ogc_search' -r 'https://raw.githubusercontent.com/open-data/ogc_search/master/requirements.txt'

    # install request with security modules
    pip install requests[security]==2.27.1

    # install correct version of cryptography
    pip install cryptography==2.2.2

    # decativate python environment
    deactivate
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
    fi

    # copy local search settings file
    printf "${SPACER}${Cyan}${INDENT}Copy django config file to virtual environment${NC}${SPACER}"
    cp ${APP_ROOT}/_config/django/settings.py ${APP_ROOT}/django/src/ogc-search/ogc_search/ogc_search/settings.py
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ${APP_ROOT}/_config/django/settings.py to ${APP_ROOT}/django/src/ogc_search/ogc_search/settings.py: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Copy ${APP_ROOT}/_config/django/settings.py to ${APP_ROOT}/django/src/ogc_search/ogc_search/settings.py: FAIL${NC}${EOL}"
    fi

    # download yaml config files
    printf "${SPACER}${Cyan}${INDENT}Download CKAN config files${NC}${SPACER}"
    mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/ckan_config_files
    cd ${APP_ROOT}/django/src/ogc-search/ogc_search/ckan_config_files
    wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/schemas/presets.yaml
    wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/briefingt.yaml
    wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/contracts.yaml
    wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/grants.yaml
    wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/nap.yaml
    wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/qpnotes.yaml
    wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/service.yaml
    wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/choices/minister.json
    wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/schemas/prop.yaml

    # set ownership
    cd ${APP_ROOT}/django
    chown django:django -R ${APP_ROOT}/django
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set django ownership to django:django: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set django ownership to django:django: FAIL${NC}${EOL}"
    fi

fi
# END
# Install OGC Django App
# END