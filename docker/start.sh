#!/usr/bin/env bash

set -e

env=${DOCKER_ENV:-production}
role=${CONTAINER_ROLE:-app}

echo "The Environment is $env"

echo "Removing XDebug"
rm -rf /usr/local/etc/php/conf.d/{docker-php-ext-xdebug.ini,xdebug.ini}

echo "The role is $role"

if [[ "$role" = "drupal" ]]; then

    # link drupal supervisord config
    ln -sf /etc/supervisor/conf.d-available/drupal.conf /etc/supervisor/conf.d/drupal.conf

    # link drupal nginx server block
    ln -sf /etc/nginx/sites-available/open.local /etc/nginx/sites-enabled/open.local

    # commented out for now
    #ln -sf /etc/nginx/sites-available/mailhog /etc/nginx/sites-enabled/mailhog

    # set the nginx user to the environment variable and reload nginx service
    nginx -g "user ${NGINX_UNAME};"
    service nginx reload

elif [[ "$role" = "ckan" ]]; then

    # link ckan supervisord config
    ln -sf /etc/supervisor/conf.d-available/ckan.conf /etc/supervisor/conf.d/ckan.conf

    # create directory for python venv
    mkdir -p ${APP_ROOT}/ckan/default

    # initiate python venv and go into it
    virtualenv --python=python2 ${APP_ROOT}/ckan/default
    . ${APP_ROOT}/ckan/default/bin/activate

    # install base dependencies
    pip install setuptools==${SETUP_TOOLS_VERSION}
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

elif [[ "$role" = "solr" ]]; then

    # link solr supervisord config
    ln -sf /etc/supervisor/conf.d-available/solr.conf /etc/supervisor/conf.d/solr.conf

    # copy all local core data to solr data directory
    cp -R /var/solr/local_data/* /var/solr/data
    chown -R solr:root /var/solr/data

elif [[ "$role" = "scheduler" ]]; then

    ln -sf /etc/supervisor/conf.d-available/scheduler.conf /etc/supervisor/conf.d/scheduler.conf

    # while [ true ]
    # do
    #     php /var/www/html/artisan schedule:run --verbose --no-interaction &
    #     sleep 60
    # done

elif [[ "$role" = "queue" ]]; then

    ln -sf /etc/supervisor/conf.d-available/queue.conf /etc/supervisor/conf.d/queue.conf
    # echo "Running the queue"
    # exec php /var/www/html/artisan queue:work --verbose --tries=1 --timeout=90

else

    echo "Could not match the container role \"$role\""
    exit 1

fi

echo "Executing supervisord"
exec supervisord -c /etc/supervisor/supervisord.conf
