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

    # install oc search into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}OC Search repository${HAIR}${Cyan} from https://github.com:open-data/oc_search.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/oc_search.git#egg=oc_search' -r 'https://raw.githubusercontent.com/open-data/oc_search/master/requirements.txt'

    # install open-data SolrClient into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}Solr Client repository${HAIR}${Cyan} from https://github.com/open-data/SolrClient.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/SolrClient.git#egg=SolrClient' -r 'https://raw.githubusercontent.com/open-data/SolrClient/master/requirements.txt'

    # install request with security modules
    pip install requests[security]==2.27.1

    # install correct version of cryptography
    pip install cryptography==2.2.2

    # install correct versions
    pip install Babel==2.12.1
    pip install bleach==6.0.0
    pip install celery==5.2.7
    pip install ckanapi==4.7
    pip install django==3.2.20
    pip install django-celery-beat==2.5.0
    pip install django-celery-results==2.5.1
    pip install django-cors-headers==3.13.0
    pip install django-jazzmin==2.6.0
    pip install django-qurl-templatetag==0.0.14
    pip install django-redis-cache==3.0.1
    pip install django-redis-sessions==0.6.2
    pip install django-smuggler==1.0.4
    pip install docutils==0.20.1
    pip install email-validator==2.0.0.post2
    pip install inflection==0.5.1
    pip install markdown2==2.4.8
    pip install nltk==3.8.1
    #pip install pandas==1.4.3
    pip install psycopg2==2.9.6
    pip install python-dateutil==2.8.2
    pip install PyYAML==6.0
    pip install Unidecode==1.3.6
    pip install uWSGI==2.0.19.1

    # decativate python environment
    deactivate
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
    fi

    # copy local search settings file
    printf "${SPACER}${Cyan}${INDENT}Copy django config file to virtual environment${NC}${SPACER}"
    cp ${APP_ROOT}/_config/django/settings.py ${APP_ROOT}/django/src/oc-search/oc_search/settings.py
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ${APP_ROOT}/_config/django/settings.py to ${APP_ROOT}/django/src/oc-search/oc_search/settings.py: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Copy ${APP_ROOT}/_config/django/settings.py to ${APP_ROOT}/django/src/oc-search/oc_search/settings.py: FAIL${NC}${EOL}"
    fi

    # download yaml config files
    printf "${SPACER}${Cyan}${INDENT}Download CKAN config files${NC}${SPACER}"
    mkdir -p ${APP_ROOT}/django/src/oc-search/oc_search/ckan_config_files
    cd ${APP_ROOT}/django/src/oc-search/oc_search/ckan_config_files
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
# Install OC Django App
# END
