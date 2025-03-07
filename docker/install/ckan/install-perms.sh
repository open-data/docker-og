#!/bin/bash

#
# Set file permissions
#
if [[ $installFilePermissions_CKAN == "true" ]]; then

    # set file ownership for ckan files
    chown ckan:ckan -R ${APP_ROOT}/ckan
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set ckan ownership to ckan:ckan: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set ckan ownership to ckan:ckan: FAIL${NC}${EOL}"
    fi

    # set file ownership for ckan static files
    chown ckan:ckan -R ${APP_ROOT}/ckan/static_files
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set ckan/static_files ownership to ckan:ckan: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set ckan/static_files ownership to ckan:ckan: FAIL${NC}${EOL}"
    fi

    # initialize databases
    ckan -c ${APP_ROOT}/ckan/registry.ini db init
    ckan -c ${APP_ROOT}/ckan/portal.ini db init

    # initialize validation tables
    ckan -c ${APP_ROOT}/ckan/registry.ini validation init-db

    # set database permissions
    ckan -c ${APP_ROOT}/ckan/registry.ini datastore set-permissions | psql -U homestead --set ON_ERROR_STOP=1
    ckan -c ${APP_ROOT}/ckan/portal.ini datastore set-permissions | psql -U homestead --set ON_ERROR_STOP=1

    # update triggers
    ckan -c ${APP_ROOT}/ckan/registry.ini canada update-triggers

fi
# END
# Set file permissions
# END
