#!/bin/bash

#
# Set file permissions
#
if [[ $installFilePermissions_CKAN == "true" ]]; then

    # set file ownership for ckan files
    chown ckan:ckan -R ${APP_ROOT}/ckan/${CKAN_ROLE}
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: FAIL${NC}${EOL}"
    fi

    # set file ownership for ckan static files
    chown ckan:ckan -R ${APP_ROOT}/ckan/static_files
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set ckan/static_files ownership to ckan:ckan: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set ckan/static_files ownership to ckan:ckan: FAIL${NC}${EOL}"
    fi

    # initialize databases
    paster --plugin=ckan db init -c ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini

    # initialize validation tables
    paster --plugin=ckanext-validation validation init-db -c ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini

    # set database permissions
    paster --plugin=ckan datastore set-permissions -c ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini | psql -U homestead --set ON_ERROR_STOP=1

fi
# END
# Set file permissions
# END