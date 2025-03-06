#!/bin/bash

#
# Install OC Django App
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

    mkdir -p ${APP_ROOT}/django/src

    # pull oc search
    cd ${APP_ROOT}/django/src
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}OC Search repository${HAIR}${Cyan} from https://github.com:open-data/oc_search.git and installing requirements into Python environment${NC}${SPACER}"
    git clone https://github.com/open-data/oc_search.git
    cd ${APP_ROOT}/django/src/oc_search
    pip install -r requirements-test.txt

    # pull oc search definitions
    cd ${APP_ROOT}/django/src
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}OC Search Definitions repository${HAIR}${Cyan} from https://github.com:open-data/oc_searches.git${NC}${SPACER}"
    git clone https://github.com/open-data/oc_searches.git

    # install open-data SolrClient into the python environment
    cd ${APP_ROOT}/django
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}Solr Client repository${HAIR}${Cyan} from https://github.com/open-data/SolrClient.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/SolrClient.git#egg=SolrClient' -r 'https://raw.githubusercontent.com/open-data/SolrClient/master/requirements.txt'

    pip install nltk==3.8.1
    python -m nltk.downloader wordnet

    # decativate python environment
    deactivate
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
    fi

    # copy local search settings file
    printf "${SPACER}${Cyan}${INDENT}Copy django config file to virtual environment${NC}${SPACER}"
    cp ${APP_ROOT}/_config/django/settings.py ${APP_ROOT}/django/src/oc_search/oc_search/settings.py
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ${APP_ROOT}/_config/django/settings.py to ${APP_ROOT}/django/src/oc_search/oc_search/settings.py: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Copy ${APP_ROOT}/_config/django/settings.py to ${APP_ROOT}/django/src/oc_search/oc_search/settings.py: FAIL${NC}${EOL}"
    fi

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
# Install OC Django App
# END
