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

    mkdir -p /etc/nginx/sites-available
    mkdir -p /etc/nginx/sites-enabled

    # remove default server block
    rm -vf /etc/nginx/sites-enabled/default

    # link proxy nginx server block
    ln -sf /etc/nginx/sites-available/proxy /etc/nginx/sites-enabled/proxy

    # link mkcert certificate to the truststore
    printf "${Green}Adding mkcert to truststores${NC}${EOL}"
    ln -sf /etc/ssl/mkcert/rootCA.pem /etc/ssl/certs/mkcert-certificate.pem
    mkdir -p /usr/local/share/ca-certificates
    cp /etc/ssl/mkcert/rootCA.pem /usr/local/share/ca-certificates/mkcert-certificate.crt
    update-ca-certificates

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    supervisord -c /etc/supervisor/supervisord.conf

# END
# Proxy
# END
elif [[ "$role" = "drupal" ]]; then
#
# Drupal
#

    # link drupal supervisord config
    ln -sf /etc/supervisor/conf.d-available/drupal.conf /etc/supervisor/conf.d/drupal.conf

    mkdir -p /etc/nginx/sites-available
    mkdir -p /etc/nginx/sites-enabled

    # remove default server block
    rm -vf /etc/nginx/sites-enabled/default

    # link drupal nginx server block
    ln -sf /etc/nginx/sites-available/open.local /etc/nginx/sites-enabled/open.local

    # link mkcert certificate to the truststore
    printf "${Green}Adding mkcert to truststores${NC}${EOL}"
    ln -sf /etc/ssl/mkcert/rootCA.pem /etc/ssl/certs/mkcert-certificate.pem
    mkdir -p /usr/local/share/ca-certificates
    cp /etc/ssl/mkcert/rootCA.pem /usr/local/share/ca-certificates/mkcert-certificate.crt
    update-ca-certificates

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    supervisord -c /etc/supervisor/supervisord.conf

# END
# Drupal
# END
elif [[ "$role" = "ckan" ]]; then
#
# CKAN Registry & Portal
#
    # link ckan supervisord config
    ln -sf /etc/supervisor/conf.d-available/ckan.conf /etc/supervisor/conf.d/ckan.conf

    # link mkcert certificate to the truststore
    printf "${Green}Adding mkcert to truststores${NC}${EOL}"
    ln -sf /etc/ssl/mkcert/rootCA.pem /etc/ssl/certs/mkcert-certificate.pem
    mkdir -p /usr/local/share/ca-certificates
    cp /etc/ssl/mkcert/rootCA.pem /usr/local/share/ca-certificates/mkcert-certificate.crt
    update-ca-certificates

    # create directory for python venv
    mkdir -p ${APP_ROOT}/ckan/default
    mkdir -p ${APP_ROOT}/ckan/portal
    mkdir -p ${APP_ROOT}/ckan/registry

    # create directories for uwsgi outputs
    mkdir -p /dev
    chown -R ckan:ckan /dev

    # initiate python venv and go into it
    virtualenv --python=python2 ${APP_ROOT}/ckan/default
    . ${APP_ROOT}/ckan/default/bin/activate

    # install base dependencies
    pip install setuptools==${SETUP_TOOLS_VERSION}
    pip install uwsgi
    pip install --upgrade pip==${PIP_VERSION}
    pip install --upgrade certifi

    # copy mkcert CA root to the python CA root
    cp /etc/ssl/mkcert/rootCA.pem /srv/app/ckan/default/lib/python${PY_VERSION}/site-packages/certifi/cacert.pem
    if [[ $? -eq 0 ]]; then
        printf "${Green}Copied /etc/ssl/mkcert/rootCA.pem to /srv/app/ckan/default/lib/python${PY_VERSION}/site-packages/certifi/cacert.pem${NC}${EOL}"
    else
        printf "${Red}FAILED to copy /etc/ssl/mkcert/rootCA.pem to /srv/app/ckan/default/lib/python${PY_VERSION}/site-packages/certifi/cacert.pem${NC}${EOL}"
    fi

    # exit python venv
    deactivate

    # copy default environment into portal and registry environments
    cp -R ${APP_ROOT}/ckan/default/* ${APP_ROOT}/ckan/portal/
    cp -R ${APP_ROOT}/ckan/default/* ${APP_ROOT}/ckan/registry/

    # copy the ckan configs
    cp ${APP_ROOT}/ckan.ini ${APP_ROOT}/ckan/default/ckan.ini
    cp ${APP_ROOT}/portal.ini ${APP_ROOT}/ckan/portal/portal.ini
    cp ${APP_ROOT}/registry.ini ${APP_ROOT}/ckan/registry/registry.ini

    # create storage paths
    mkdir -p ${APP_ROOT}/ckan/default/storage
    mkdir -p ${APP_ROOT}/ckan/portal/storage
    mkdir -p ${APP_ROOT}/ckan/registry/storage

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    supervisord -c /etc/supervisor/supervisord.conf

# END
# CKAN Registry & Portal
# END
elif [[ "$role" = "solr" ]]; then
#
# Solr
#

    # link solr supervisord config
    ln -sf /etc/supervisor/conf.d-available/solr.conf /etc/supervisor/conf.d/solr.conf

    # copy all local core data to solr data directory
    printf "${Green}Loading local cores${NC}${EOL}"
    cp -R /var/solr/local_data/* /var/solr/data
    chown -R solr:root /var/solr/data

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    supervisord -c /etc/supervisor/supervisord.conf

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
