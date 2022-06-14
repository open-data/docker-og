#!/usr/bin/env bash

set -e

env=${DOCKER_ENV:-production}
role=${CONTAINER_ROLE:-app}
ckanRole=${CKAN_ROLE:-registry}

Cyan='\033[0;36m'
Yellow='\033[1;33m'
Red='\033[0;31m'
Green='\033[0;32m'
NC='\033[0;0m'
EOL='\n'
BOLD='\033[1m'
HAIR='\033[0m'

printf "${Cyan}The Environment is ${BOLD}$env${HAIR}${NC}${EOL}"

printf "${Yellow}Removing XDebug${NC}${EOL}"
rm -rf /usr/local/etc/php/conf.d/{docker-php-ext-xdebug.ini,xdebug.ini}

printf "${Cyan}The role is ${BOLD}$role${HAIR}${NC}${EOL}"

if [[ "$role" = "proxy" ]]; then
#
# Proxy
#

    # link proxy supervisord config
    ln -sf /etc/supervisor/conf.d-available/proxy.conf /etc/supervisor/conf.d/proxy.conf

    # change volume ownerships
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown www-data:www-data -R /var/ogproxy"

    mkdir -p /etc/nginx/sites-available
    mkdir -p /etc/nginx/sites-enabled

    # remove default server block
    rm -vf /etc/nginx/sites-enabled/default

    # link proxy nginx server block
    ln -sf /etc/nginx/sites-available/open.local /etc/nginx/sites-enabled/open.local
    ln -sf /etc/nginx/sites-available/portal.open.local /etc/nginx/sites-enabled/portal.open.local
    ln -sf /etc/nginx/sites-available/registry.open.local /etc/nginx/sites-enabled/registry.open.local
    ln -sf /etc/nginx/sites-available/search.open.local /etc/nginx/sites-enabled/search.open.local
    ln -sf /etc/nginx/sites-available/solr.open.local /etc/nginx/sites-enabled/solr.open.local

    # stop nginx service
    printf "${Green}Stopping nginx service${NC}${EOL}"
    service nginx stop

    # change volume ownerships
    printf "${Green}Setting volume ownership${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown www-data:www-data -R /var/ogproxy"

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "supervisord -c /etc/supervisor/supervisord.conf"

# END
# Proxy
# END
elif [[ "$role" = "drupal" ]]; then
#
# Drupal
#

    # link drupal supervisord config
    ln -sf /etc/supervisor/conf.d-available/drupal.conf /etc/supervisor/conf.d/drupal.conf

    # change volume ownerships
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown www-data:www-data -R /var/www/html"

    mkdir -p /etc/nginx/sites-available
    mkdir -p /etc/nginx/sites-enabled

    # remove default server block
    rm -vf /etc/nginx/sites-enabled/default

    # link drupal nginx server block
    ln -sf /etc/nginx/sites-available/open.local /etc/nginx/sites-enabled/open.local

    # copy the drupal configs
    if [[ -d "${APP_ROOT}/drupal/html/sites" ]]; then
        printf "${Green}Copying the Drupal configuration file to the installation${NC}${EOL}"
        cp ${APP_ROOT}/_config/drupal/settings.php ${APP_ROOT}/drupal/html/sites/settings.php
        if [[ -d "${APP_ROOT}/drupal/html/sites/default" ]]; then
            cp ${APP_ROOT}/_config/drupal/settings.php ${APP_ROOT}/drupal/html/sites/default/settings.php
        fi

        printf "${Green}Copying the Drupal services file to the installation${NC}${EOL}"
        cp ${APP_ROOT}/_config/drupal/services.yml ${APP_ROOT}/drupal/html/sites/development.services.yml
        if [[ -d "${APP_ROOT}/drupal/html/sites/default" ]]; then
            cp ${APP_ROOT}/_config/drupal/services.yml ${APP_ROOT}/drupal/html/sites/default/development.services.yml
        fi
    fi

    # stop nginx service
    printf "${Green}Stopping nginx service${NC}${EOL}"
    service nginx stop

    # change volume ownerships
    printf "${Green}Setting volume ownership${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown www-data:www-data -R /var/www/html"

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "supervisord -c /etc/supervisor/supervisord.conf"

# END
# Drupal
# END
elif [[ "$role" = "search" ]]; then
#
# Django
#

    # link django supervisord config
    ln -sf /etc/supervisor/conf.d-available/django.conf /etc/supervisor/conf.d/django.conf

    # change volume ownerships
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown django:django -R /var/ocs"

    # copy the django settings file
    if [[ -d "${APP_ROOT}/django/src/ogc-search/ogc_search/ogc_search" ]]; then
        printf "${Green}Copying the Django settings file to the virtual environment${NC}${EOL}"
        cp ${APP_ROOT}/_config/django/settings.py ${APP_ROOT}/django/src/ogc-search/ogc_search/ogc_search/settings.py
    fi;

    # change volume ownerships
    printf "${Green}Setting volume ownership${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown django:django -R /var/ocs"

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "supervisord -c /etc/supervisor/supervisord.conf"

# END
# Django
# END
elif [[ "$role" = "ckan" ]]; then
#
# CKAN Registry & Portal
#

    printf "${Cyan}The CKAN role is ${BOLD}$ckanRole${HAIR}${NC}${EOL}"

    # link ckan supervisord config
    ln -sf /etc/supervisor/conf.d-available/ckan-${ckanRole}.conf /etc/supervisor/conf.d/ckan-${ckanRole}.conf

    # change volume ownerships
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown ckan:ckan -R /srv/app"

    # create directory for python venv
    mkdir -p ${APP_ROOT}/ckan/${ckanRole}

    # create directory for ckan static files
    mkdir -p ${APP_ROOT}/ckan/static_files

    # create directories for uwsgi outputs
    mkdir -p /dev
    chown -R ckan:ckan /dev

    # create i18n paths
    if [[ -d "/srv/app/ckan/${ckanRole}/src/ckanext-canada" ]]; then
        mkdir -p /srv/app/ckan/${ckanRole}/src/ckanext-canada/build;
        if [[ $? -eq 0 ]]; then
            printf "${Green}Created /srv/app/ckan/${ckanRole}/src/ckanext-canada/build${NC}${EOL}";
        else
            printf "${Red}FAILED to create /srv/app/ckan/${ckanRole}/src/ckanext-canada/build (directory may already exist)${NC}${EOL}";
        fi;
    fi;

    # copy the ckan configs
    printf "${Green}Copying the ${ckanRole} configuration file to the virtual environment${NC}${EOL}"
    cp ${APP_ROOT}/_config/ckan/${ckanRole}.ini ${APP_ROOT}/ckan/${ckanRole}/${ckanRole}.ini

    # copy the ckan configs
    printf "${Green}Copying the ${ckanRole} test configuration file to the virtual environment${NC}${EOL}"
    cp ${APP_ROOT}/_config/ckan/${ckanRole}-test.ini ${APP_ROOT}/ckan/${ckanRole}/test.ini

    # copy the wsgi.py files
    printf "${Green}Copying the ${ckanRole} wsgi configuration file to the virtual environment${NC}${EOL}"
    cp ${APP_ROOT}/docker/config/ckan/wsgi/${ckanRole}.py ${APP_ROOT}/ckan/${ckanRole}/wsgi.py
    chown ckan:ckan ${APP_ROOT}/ckan/${ckanRole}/wsgi.py

    # create storage paths
    printf "${Green}Generating storage directory${NC}${EOL}"
    mkdir -p ${APP_ROOT}/ckan/${ckanRole}/storage
    chown -R ckan:ckan ${APP_ROOT}/ckan/${ckanRole}/storage

    # create cache paths
    printf "${Green}Generating cache directory${NC}${EOL}"
    mkdir -p ${APP_ROOT}/ckan/${ckanRole}/tmp
    chown -R ckan:ckan ${APP_ROOT}/ckan/${ckanRole}/tmp

    # copy ckanext-canada static to static_files
    if [[ -d "${APP_ROOT}/ckan/${ckanRole}/src/ckanext-canada/ckanext/canada/public/static" ]]; then
        cp -R ${APP_ROOT}/ckan/${ckanRole}/src/ckanext-canada/ckanext/canada/public/static ${APP_ROOT}/ckan/static_files/;
        if [[ $? -eq 0 ]]; then
            printf "${Green}Copied ${APP_ROOT}/ckan/${ckanRole}/src/ckanext-canada/ckanext/canada/public/static to ${APP_ROOT}/ckan/static_files/static${NC}${EOL}";
        else
            printf "${Red}FAILED to copy ${APP_ROOT}/ckan/${ckanRole}/src/ckanext-canada/ckanext/canada/public/static to ${APP_ROOT}/ckan/static_files/static${NC}${EOL}";
        fi;
        chown -R ckan:ckan ${APP_ROOT}/ckan/static_files
    fi;

    # install nltk punkt
    if [[ $ckanRole == 'portal' ]]; then
        if [[ -d "${APP_ROOT}/ckan/${ckanRole}/lib/python${PY_VERSION}/site-packages/nltk" ]]; then
            printf "${Green}Installing nltk.punkt into ${ckanRole} environment${NC}${EOL}"
            ${APP_ROOT}/ckan/${ckanRole}/bin/python2 -c "import nltk; nltk.download('punkt');"
        fi;
    fi;

    # change volume ownerships
    printf "${Green}Setting volume ownership${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown ckan:ckan -R /srv/app"

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "supervisord -c /etc/supervisor/supervisord.conf"

# END
# CKAN Registry & Portal
# END
elif [[ "$role" = "solr" ]]; then
#
# Solr
#

    # link solr supervisord config
    ln -sf /etc/supervisor/conf.d-available/solr.conf /etc/supervisor/conf.d/solr.conf

    # change volume ownerships
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown solr:solr -R /var/solr"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown solr:solr -R /opt/solr"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown solr:solr -R /opt/docker-solr"

    # copy all local core data to solr data directory
    printf "${Green}Loading local cores${NC}${EOL}"
    cp -R /var/solr/local_data/* /var/solr/data

    # link the cores
    printf "${Green}Linking cores${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c  "ln -s /var/solr/data /opt/solr/server/cores"

    # create solr logs directory
    printf "${Green}Creating solr logs directory${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c  "mkdir -p /opt/solr/server/logs"

    # change volume ownerships
    printf "${Green}Setting volume ownership${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown solr:solr -R /var/solr"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown solr:solr -R /opt/solr"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown solr:solr -R /opt/docker-solr"

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "supervisord -c /etc/supervisor/supervisord.conf"

# END
# Solr
# END
elif [[ "$role" = "scheduler" ]]; then

    # link scheduler supervisord config
    ln -sf /etc/supervisor/conf.d-available/scheduler.conf /etc/supervisor/conf.d/scheduler.conf

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    supervisord -c /etc/supervisor/supervisord.conf

elif [[ "$role" = "queue" ]]; then

    # link queue supervisord config
    ln -sf /etc/supervisor/conf.d-available/queue.conf /etc/supervisor/conf.d/queue.conf

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    supervisord -c /etc/supervisor/supervisord.con

else

    printf "${Red}Could not match the container role \"${BOLD}$role${HAIR}\"${NC}${EOL}"
    exit 1

fi
