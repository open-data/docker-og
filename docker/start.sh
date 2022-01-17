#!/usr/bin/env bash

set -e

env=${DOCKER_ENV:-production}
role=${CONTAINER_ROLE:-app}

echo "The Environment is $env"

#if [ "$env" != "local" ]; then
#
#    (
#        cd /var/www/html &&
#        php artisan config:cache &&
#        php artisan route:cache &&
#        php artisan view:cache
#    )

    echo "Removing XDebug"
    rm -rf /usr/local/etc/php/conf.d/{docker-php-ext-xdebug.ini,xdebug.ini}
#fi

echo "The role is $role..."

if [ "$role" = "app" ]; then
    ln -sf /etc/supervisor/conf.d-available/app.conf /etc/supervisor/conf.d/app.conf
    ln -s /etc/nginx/sites-available/mailhog /etc/nginx/sites-enabled/
    service nginx reload
elif [ "$role" = "scheduler" ]; then
    ln -sf /etc/supervisor/conf.d-available/scheduler.conf /etc/supervisor/conf.d/scheduler.conf
    # while [ true ]
    # do
    #     php /var/www/html/artisan schedule:run --verbose --no-interaction &
    #     sleep 60
    # done
elif [ "$role" = "queue" ]; then
    ln -sf /etc/supervisor/conf.d-available/queue.conf /etc/supervisor/conf.d/queue.conf
    # echo "Running the queue"
    # exec php /var/www/html/artisan queue:work --verbose --tries=1 --timeout=90
else
    echo "Could not match the container role \"$role\""
    exit 1
fi

exec supervisord -c /etc/supervisor/supervisord.conf
