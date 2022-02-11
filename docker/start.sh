#!/usr/bin/env bash

set -e

env=${DOCKER_ENV:-production}
role=${CONTAINER_ROLE:-app}
ckanRole=${CKAN_ROLE:-registry}

echo "The Environment is $env"

echo "Removing XDebug"
rm -rf /usr/local/etc/php/conf.d/{docker-php-ext-xdebug.ini,xdebug.ini}

echo "The role is $role"

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
    ln -sf /etc/ssl/mkcert/rootCA.pem /etc/ssl/certs/mkcert-certificate.pem
    mkdir -p /usr/local/share/ca-certificates
    cp /etc/ssl/mkcert/rootCA.pem /usr/local/share/ca-certificates/mkcert-certificate.crt
    update-ca-certificates

    # set the nginx user to the environment variable and reload nginx service
    nginx -g "user ${NGINX_UNAME};"
    nginx -g "daemon off;"
    service nginx reload

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
    ln -sf /etc/ssl/mkcert/rootCA.pem /etc/ssl/certs/mkcert-certificate.pem
    mkdir -p /usr/local/share/ca-certificates
    cp /etc/ssl/mkcert/rootCA.pem /usr/local/share/ca-certificates/mkcert-certificate.crt
    update-ca-certificates

    # set the nginx user to the environment variable and reload nginx service
    nginx -g "user ${NGINX_UNAME};"
    nginx -g "daemon off;"
    service nginx reload

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
        echo "Copied /etc/ssl/mkcert/rootCA.pem to /srv/app/ckan/default/lib/python${PY_VERSION}/site-packages/certifi/cacert.pem"
    else
        printf "FAILED to copy /etc/ssl/mkcert/rootCA.pem to /srv/app/ckan/default/lib/python${PY_VERSION}/site-packages/certifi/cacert.pem"
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
    cp -R /var/solr/local_data/* /var/solr/data
    chown -R solr:root /var/solr/data

# END
# Solr
# END
elif [[ "$role" = "scheduler" ]]; then

    # link scheduler supervisord config
    ln -sf /etc/supervisor/conf.d-available/scheduler.conf /etc/supervisor/conf.d/scheduler.conf

elif [[ "$role" = "queue" ]]; then

    # link queue supervisord config
    ln -sf /etc/supervisor/conf.d-available/queue.conf /etc/supervisor/conf.d/queue.conf

else

    echo "Could not match the container role \"$role\""
    exit 1

fi

echo "Executing supervisord"
exec supervisord -c /etc/supervisor/supervisord.conf
