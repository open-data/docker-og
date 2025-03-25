#!/bin/bash

set -e

env=${DOCKER_ENV:-production}
role=${CONTAINER_ROLE:-app}

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
echo ${ROOT_PASS} | sudo -S /bin/bash -c "rm -rf /usr/local/etc/php/conf.d/{docker-php-ext-xdebug.ini,xdebug.ini}"

printf "${Cyan}The role is ${BOLD}$role${HAIR}${NC}${EOL}"

if [[ "$role" = "proxy" ]]; then
#
# Proxy
#

    # stop nginx service
    printf "${Green}Stopping nginx service${NC}${EOL}"
    if [[ $(which service) ]]; then
        service nginx stop
    elif [[ $(which nginx) ]]; then
        nginx stop
    else
        printf "${Red}FAILED to stop nginx service. Service and Nginx not found in PATH${NC}${EOL}";
    fi

    # link proxy supervisord config
    ln -sf /etc/supervisor/conf.d-available/proxy.conf /etc/supervisor/conf.d/proxy.conf

    # change volume ownerships
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown www-data:www-data -R /var/ogproxy"

    mkdir -p /etc/nginx/sites-available
    mkdir -p /etc/nginx/sites-enabled

    # remove default server block
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "rm -vf /etc/nginx/sites-enabled/default"

    # change nginx ownerships
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown www-data:www-data -R /etc/nginx"

    # link proxy nginx server block
    ln -sf /etc/nginx/sites-available/open.local /etc/nginx/sites-enabled/open.local
    ln -sf /etc/nginx/sites-available/portal.open.local /etc/nginx/sites-enabled/portal.open.local
    ln -sf /etc/nginx/sites-available/registry.open.local /etc/nginx/sites-enabled/registry.open.local
    ln -sf /etc/nginx/sites-available/search.open.local /etc/nginx/sites-enabled/search.open.local
    ln -sf /etc/nginx/sites-available/solr.open.local /etc/nginx/sites-enabled/solr.open.local

    # change volume ownerships
    printf "${Green}Setting volume ownership${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown www-data:www-data -R /var/ogproxy"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "mkdir -p /home/www-data && chown www-data:www-data -R /home/www-data"

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown www-data:www-data -R /etc/supervisor"
    echo ${ROOT_PASS} | sudo -S -E /bin/bash -c "supervisord -c /etc/supervisor/supervisord.conf"

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
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "rm -vf /etc/nginx/sites-enabled/default"

    # change nginx ownerships
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown www-data:www-data -R /etc/nginx"

    # link drupal nginx server block
    ln -sf /etc/nginx/sites-available/open.local /etc/nginx/sites-enabled/open.local

    # create socket file
    printf "${Green}Create php-fpm socket file${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "mkdir -p /usr/local/var/run && touch /usr/local/var/run/php-fpm.sock"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown www-data:www-data -R /usr/local/var/run/php-fpm.sock"

    # copy the drupal configs
    if [[ -d "${APP_ROOT}/drupal/html/sites" ]]; then
        printf "${Green}Copying the Drupal configuration file to the installation${NC}${EOL}"
        cp ${APP_ROOT}/_config/drupal/settings.php ${APP_ROOT}/drupal/html/sites/settings.php
        if [[ -d "${APP_ROOT}/drupal/html/sites/default" ]]; then
            cp ${APP_ROOT}/_config/drupal/settings.php ${APP_ROOT}/drupal/html/sites/default/settings.php
        fi

        printf "${Green}Copying the Drupal Blog configuration file to the installation${NC}${EOL}"
        cp ${APP_ROOT}/_config/drupal/blog_settings.php ${APP_ROOT}/drupal/html/sites/tbsblog.ca/settings.php

        printf "${Green}Copying the Drupal Guides configuration file to the installation${NC}${EOL}"
        if [[ ! -d "${APP_ROOT}/drupal/html/sites/guides" ]]; then
            mkdir -p ${APP_ROOT}/drupal/html/sites/guides
        fi
        cp ${APP_ROOT}/_config/drupal/guides_settings.php ${APP_ROOT}/drupal/html/sites/guides/settings.php

        printf "${Green}Copying the Drupal Sites configuration file to the installation${NC}${EOL}"
        cp ${APP_ROOT}/_config/drupal/sites.php ${APP_ROOT}/drupal/html/sites/sites.php

        printf "${Green}Copying the Drupal services file to the installation${NC}${EOL}"
        cp ${APP_ROOT}/_config/drupal/services.yml ${APP_ROOT}/drupal/html/sites/development.services.yml
        if [[ -d "${APP_ROOT}/drupal/html/sites/default" ]]; then
            cp ${APP_ROOT}/_config/drupal/services.yml ${APP_ROOT}/drupal/html/sites/default/development.services.yml
        fi
    fi

    # stop nginx service
    printf "${Green}Stopping nginx service${NC}${EOL}"
    if [[ $(which service) ]]; then
        service nginx stop
    elif [[ $(which nginx) ]]; then
        nginx stop
    else
        printf "${Red}FAILED to stop nginx service. Service and Nginx not found in PATH${NC}${EOL}";
    fi

    # change volume ownerships
    printf "${Green}Setting volume ownership${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown www-data:www-data -R /var/www/html"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "mkdir -p /home/www-data && chown www-data:www-data -R /home/www-data"

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown www-data:www-data -R /etc/supervisor"
    echo ${ROOT_PASS} | sudo -S -E /bin/bash -c "supervisord -c /etc/supervisor/supervisord.conf"

# END
# Drupal
# END
elif [[ "$role" = "search" ]]; then
#
# Django
#
    djangoPath='django'
    # link django supervisord config
    ln -sf /etc/supervisor/conf.d-available/django.conf /etc/supervisor/conf.d/django.conf

    # change volume ownerships
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown django:django -R ${APP_ROOT}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "mkdir -p /home/django && chown django:django -R /home/django"

    # create directory for python venv
    mkdir -p ${APP_ROOT}/${djangoPath}

    # create directory for django static files
    mkdir -p ${APP_ROOT}/${djangoPath}/static

    # create directory for supervisord chdir
    mkdir -p ${APP_ROOT}/${djangoPath}/src/oc_search

    # create fresh pid directory
    if [[ -d "/usr/local/var/run/django" ]]; then
      echo ${ROOT_PASS} | sudo -S /bin/bash -c "rm -rf /usr/local/var/run/django"
    fi;
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "mkdir -p /usr/local/var/run/django"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown django:django -R /usr/local/var/run/django"

    # create directories for log outputs
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "mkdir -p /dev"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown -R django:django /dev"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "mkdir -p /var/log/django"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "mkdir -p /var/log/celery"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown -R django:django /var/log/django"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown -R django:django /var/log/celery"

    # copy the django settings file
    if [[ -d "${APP_ROOT}/${djangoPath}/src/oc_search/oc_search" ]]; then
        printf "${Green}Copying the Django settings file to the virtual environment${NC}${EOL}"
        cp ${APP_ROOT}/_config/django/settings.py ${APP_ROOT}/${djangoPath}/src/oc_search/oc_search/settings.py
    fi;

    # copy the wsgi.py files
    if [[ -d "${APP_ROOT}/${djangoPath}" ]]; then
      printf "${Green}Copying the wsgi configuration file to the virtual environment${NC}${EOL}"
      cp ${APP_ROOT}/docker/config/django/wsgi.py ${APP_ROOT}/${djangoPath}/wsgi.py
      chown django:django ${APP_ROOT}/${djangoPath}/wsgi.py

      printf "${Green}Copying the activation file to the virtual environment${NC}${EOL}"
      cp ${APP_ROOT}/docker/config/django/activate_this.py ${APP_ROOT}/${djangoPath}/bin/activate_this.py
      chown django:django ${APP_ROOT}/${djangoPath}/bin/activate_this.py
    fi;

    # install nltk depends
    if [[ -d "${APP_ROOT}/${djangoPath}/bin" ]]; then
      source ${APP_ROOT}/${djangoPath}/bin/activate
      pip install nltk==3.8.1
      python -m nltk.downloader wordnet
      deactivate
    fi;

    # change volume ownerships
    printf "${Green}Setting volume ownership${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown django:django -R ${APP_ROOT}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "mkdir -p /home/django && chown django:django -R /home/django"

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown django:django -R /etc/supervisor"
    echo ${ROOT_PASS} | sudo -S -E /bin/bash -c "supervisord -c /etc/supervisor/supervisord.conf"

# END
# Django
# END
elif [[ "$role" = "ckan" ]]; then
#
# CKAN Registry & Portal
#
    ckanPath='ckan'
    # link ckan supervisord config
    ln -sf /etc/supervisor/conf.d-available/ckan.conf /etc/supervisor/conf.d/ckan.conf

    # change volume ownerships
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown ckan:ckan -R ${APP_ROOT}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "mkdir -p /home/ckan && chown ckan:ckan -R /home/ckan"

    # create directory for python venv
    mkdir -p ${APP_ROOT}/${ckanPath}

    # create directory for ckan static files
    mkdir -p ${APP_ROOT}/${ckanPath}/static_files

    # create directories for log outputs
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "mkdir -p /dev"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown -R ckan:ckan /dev"

    # create python3 symlink for django container
    printf "${Cyan}Trying to symlink python3 /usr/local/bin/python3 to /usr/bin/python3${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "if [[ ! -L /usr/local/bin/python3 && ! -f /usr/local/bin/python3 ]]; then ln -s /usr/bin/python3 /usr/local/bin/python3 || true; fi;"

    # create i18n paths
    if [[ -d "${APP_ROOT}/${ckanPath}/src/ckanext-canada" ]]; then
        mkdir -p ${APP_ROOT}/${ckanPath}/src/ckanext-canada/build;
        if [[ $? -eq 0 ]]; then
            printf "${Green}Created ${APP_ROOT}/${ckanPath}/src/ckanext-canada/build${NC}${EOL}";
        else
            printf "${Red}FAILED to create ${APP_ROOT}/${ckanPath}/src/ckanext-canada/build (directory may already exist)${NC}${EOL}";
        fi;
    fi;

    # copy the ckan configs
    printf "${Green}Copying the configuration files to the virtual environment${NC}${EOL}"
    cp ${APP_ROOT}/_config/ckan/registry.ini ${APP_ROOT}/${ckanPath}/registry.ini
    cp ${APP_ROOT}/_config/ckan/portal.ini ${APP_ROOT}/${ckanPath}/portal.ini

    # copy the ckan configs
    printf "${Green}Copying the test configurations file to the virtual environment${NC}${EOL}"
    cp ${APP_ROOT}/_config/ckan/test.ini ${APP_ROOT}/${ckanPath}/test.ini

    # copy the ckan who configs
    printf "${Green}Copying the who.ini configuration file to the virtual environment${NC}${EOL}"
    cp ${APP_ROOT}/_config/ckan/who.ini ${APP_ROOT}/${ckanPath}/who.ini

    # misc instillations outside venv
    if [[ -d "${APP_ROOT}/${ckanPath}/bin" ]]; then
      printf "${Green}Installing misc global dependencies...${NC}${EOL}"
      echo ${ROOT_PASS} | sudo -S /bin/bash -c "pip install importlib-metadata"
      echo ${ROOT_PASS} | sudo -S /bin/bash -c "pip install supervisor==4.2.2"
    fi;

    ## NOTE: uncomment if needed
    ## ckan instillations inside venv
    # if [[ -d "${APP_ROOT}/${ckanPath}/bin" && -d "${APP_ROOT}/${ckanPath}/src/ckan" ]]; then
    #   printf "${Green}Installing ckan venv dependencies...${NC}${EOL}"
    #   source ${APP_ROOT}/${ckanPath}/bin/activate
    #   cd "${APP_ROOT}/${ckanPath}/src/ckan"
    #   pip install -r requirements.txt
    #   deactivate
    #   cd ${APP_ROOT}
    # fi;

    # copy activate this script
    if [[ -d "${APP_ROOT}/${ckanPath}/bin" ]]; then
        printf "${Green}Copying activation script to venv bin${NC}${EOL}"
        cp ${APP_ROOT}/docker/install/ckan/activate_this.py ${APP_ROOT}/${ckanPath}/bin/activate_this.py
        if [[ $? -eq 0 ]]; then
            printf "${Green}Copied activation script to ckan venv bin${NC}${EOL}";
        else
            printf "${Red}FAILED to copy activation script to ckan venv bin${NC}${EOL}";
        fi;
        chown ckan:ckan ${APP_ROOT}/${ckanPath}/bin/activate_this.py
        PYTHONPATH=${APP_ROOT}/${ckanPath}/lib/python${PY_VERSION}/site-packages
    fi;

    # compile ckan config files
    if [[ -f "${APP_ROOT}/${ckanPath}/bin/activate_this.py" ]]; then
        printf "${Green}Compiling local ckan config file${NC}${EOL}"
        ${APP_ROOT}/${ckanPath}/bin/python3 ${APP_ROOT}/docker/install/ckan/compile-registry-config.py
        if [[ $? -eq 0 ]]; then
            printf "${Green}Compiled registry ini file${NC}${EOL}";
        else
            printf "${Red}FAILED to compile registry ini file${NC}${EOL}";
        fi
        ${APP_ROOT}/${ckanPath}/bin/python3 ${APP_ROOT}/docker/install/ckan/compile-portal-config.py
        if [[ $? -eq 0 ]]; then
            printf "${Green}Compiled portal ini file${NC}${EOL}";
        else
            printf "${Red}FAILED to compile portal ini file${NC}${EOL}";
        fi
        ## NOTE: uncomment if needed
        ## run ckan setup
        # if [[ -d "${APP_ROOT}/${ckanPath}/src/ckan" ]]; then
        #     cd ${APP_ROOT}/${ckanPath}/src/ckan;
        #     ${APP_ROOT}/${ckanPath}/bin/python3 setup.py develop;
        #     if [[ $? -eq 0 ]]; then
        #         printf "${Green}Ran ckan setup${NC}${EOL}";
        #     else
        #         printf "${Red}FAILED to run ckan setup${NC}${EOL}";
        #     fi;
        #     cd ${APP_ROOT};
        # fi;
        ## NOTE: uncomment if needed
        ## run ckanext-canada setup
        # if [[ -d "${APP_ROOT}/${ckanPath}/src/ckanext-canada" ]]; then
        #     cd ${APP_ROOT}/${ckanPath}/src/ckanext-canada;
        #     ${APP_ROOT}/${ckanPath}/bin/python3 setup.py develop;
        #     if [[ $? -eq 0 ]]; then
        #         printf "${Green}Ran ckanext-canada setup${NC}${EOL}";
        #     else
        #         printf "${Red}FAILED to run ckanext-canada setup${NC}${EOL}";
        #     fi;
        #     cd ${APP_ROOT};
        # fi;
    fi;

    # copy the wsgi.py files
    printf "${Green}Copying the wsgi configurations file to the virtual environment${NC}${EOL}"
    cp ${APP_ROOT}/docker/config/${ckanPath}/wsgi/registry.py ${APP_ROOT}/${ckanPath}/registry-wsgi.py
    cp ${APP_ROOT}/docker/config/${ckanPath}/wsgi/portal.py ${APP_ROOT}/${ckanPath}/portal-wsgi.py
    chown ckan:ckan ${APP_ROOT}/${ckanPath}/registry-wsgi.py
    chown ckan:ckan ${APP_ROOT}/${ckanPath}/portal-wsgi.py

    # create storage paths
    printf "${Green}Generating storage directory${NC}${EOL}"
    mkdir -p ${APP_ROOT}/${ckanPath}/storage
    chown -R ckan:ckan ${APP_ROOT}/${ckanPath}/storage

    # create cache paths
    printf "${Green}Generating cache directory${NC}${EOL}"
    mkdir -p ${APP_ROOT}/${ckanPath}/tmp
    chown -R ckan:ckan ${APP_ROOT}/${ckanPath}/tmp

    # copy ckanext-canada static to static_files
    if [[ -d "${APP_ROOT}/${ckanPath}/src/ckanext-canada/ckanext/canada/public/static" ]]; then
        cp -R ${APP_ROOT}/${ckanPath}/src/ckanext-canada/ckanext/canada/public/static ${APP_ROOT}/${ckanPath}/static_files/;
        if [[ $? -eq 0 ]]; then
            printf "${Green}Copied ${APP_ROOT}/${ckanPath}/src/ckanext-canada/ckanext/canada/public/static to ${APP_ROOT}/${ckanPath}/static_files/static${NC}${EOL}";
        else
            printf "${Red}FAILED to copy ${APP_ROOT}/${ckanPath}/src/ckanext-canada/ckanext/canada/public/static to ${APP_ROOT}/${ckanPath}/static_files/static${NC}${EOL}";
        fi;
        chown -R ckan:ckan ${APP_ROOT}/${ckanPath}/static_files
    fi;

    ## NOTE: uncomment if needed
    ## run any database migrations
    # if [[ -f "${APP_ROOT}/${ckanPath}/bin/ckan" ]]; then
    #     printf "${Green}Running database migrations...${NC}${EOL}"
    #     ${APP_ROOT}/${ckanPath}/bin/ckan -c ${APP_ROOT}/${ckanPath}/registry.ini db upgrade
    #     ${APP_ROOT}/${ckanPath}/bin/ckan -c ${APP_ROOT}/${ckanPath}/registry.ini db upgrade --plugin=canada_public
    #     ${APP_ROOT}/${ckanPath}/bin/ckan -c ${APP_ROOT}/${ckanPath}/registry.ini db pending-migrations --apply
    #     ${APP_ROOT}/${ckanPath}/bin/ckan -c ${APP_ROOT}/${ckanPath}/registry.ini db pending-migrations --apply
    #     ${APP_ROOT}/${ckanPath}/bin/ckan -c ${APP_ROOT}/${ckanPath}/portal.ini db upgrade
    #     ${APP_ROOT}/${ckanPath}/bin/ckan -c ${APP_ROOT}/${ckanPath}/portal.ini db upgrade --plugin=canada_public
    #     ${APP_ROOT}/${ckanPath}/bin/ckan -c ${APP_ROOT}/${ckanPath}/portal.ini db pending-migrations --apply
    #     ${APP_ROOT}/${ckanPath}/bin/ckan -c ${APP_ROOT}/${ckanPath}/portal.ini db pending-migrations --apply
    # fi;

    # change volume ownerships
    printf "${Green}Setting volume ownership${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown ckan:ckan -R ${APP_ROOT}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "mkdir -p /home/ckan && chown ckan:ckan -R /home/ckan"

    # start supervisord service
    #TODO: make super fancy option to run ckan run -H 0.0.0.0 -p 5001 to allow for pdb
    printf "${Green}Executing supervisord${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown ckan:ckan -R /etc/supervisor"
    echo ${ROOT_PASS} | sudo -S -E /bin/bash -c "supervisord -c /etc/supervisor/supervisord.conf"

# END
# CKAN Registry & Portal
# END
elif [[ "$role" = "redis" ]]; then
#
# Redis
#

    # link redis supervisord config
    ln -sf /etc/supervisor/conf.d-available/redis.conf /etc/supervisor/conf.d/redis.conf

    # change volume ownerships
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown redis-og:redis-og -R /data"

    # start supervisord service
    printf "${Green}Executing supervisord${NC}${EOL}"
    echo ${ROOT_PASS} | sudo -S /bin/bash -c "chown redis-og:redis-og -R /etc/supervisor"
    echo ${ROOT_PASS} | sudo -S -E /bin/bash -c "supervisord -c /etc/supervisor/supervisord.conf"

# END
# Redis
# END
else

    printf "${Red}Could not match the container role \"${BOLD}$role${HAIR}\"${NC}${EOL}"
    exit 1

fi
