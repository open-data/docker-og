#!/usr/bin/env bash

set -e

env=${DOCKER_ENV:-production}
role=${CONTAINER_ROLE:-app}

echo "The Environment is $env"

echo "Removing XDebug"
rm -rf /usr/local/etc/php/conf.d/{docker-php-ext-xdebug.ini,xdebug.ini}

echo "The role is $role"

if [[ "$role" = "drupal" ]]; then

    ln -sf /etc/supervisor/conf.d-available/drupal.conf /etc/supervisor/conf.d/drupal.conf
    ln -sf /etc/nginx/sites-available/open.local /etc/nginx/sites-enabled/open.local
    #ln -sf /etc/nginx/sites-available/mailhog /etc/nginx/sites-enabled/mailhog
    nginx -g "user ${NGINX_UNAME};"
    service nginx reload

elif [[ "$role" = "ckan" ]]; then

    ln -sf /etc/supervisor/conf.d-available/ckan.conf /etc/supervisor/conf.d/ckan.conf
    mkdir -p ${APP_ROOT}/ckan/default
    virtualenv --python=python2 ${APP_ROOT}/ckan/default
    . ${APP_ROOT}/ckan/default/bin/activate
    pip install setuptools==${SETUP_TOOLS_VERSION}
    pip install --upgrade pip==${PIP_VERSION}
    pip install --upgrade certifi
    cp /etc/ssl/mkcert/rootCA.pem /srv/app/ckan/default/lib/python${PY_VERSION}/site-packages/certifi/cacert.pem
    if [[ $? -eq 0 ]]; then
        echo "Copied /etc/ssl/mkcert/rootCA.pem to /srv/app/ckan/default/lib/python${PY_VERSION}/site-packages/certifi/cacert.pem"
      else
        printf "FAILED to copy /etc/ssl/mkcert/rootCA.pem to /srv/app/ckan/default/lib/python${PY_VERSION}/site-packages/certifi/cacert.pem"
      fi
    deactivate

elif [[ "$role" = "solr" ]]; then

    ln -sf /etc/supervisor/conf.d-available/solr.conf /etc/supervisor/conf.d/solr.conf
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
