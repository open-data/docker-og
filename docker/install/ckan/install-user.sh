#!/bin/bash

#
# Create local user
#
if [[ $installLocalUser_CKAN == "true" ]]; then

    # activate python environment
    . ${APP_ROOT}/ckan/bin/activate
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Activate Python environment: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Activate Python environment: FAIL${NC}${EOL}"
    fi

    # create member user
    printf "${SPACER}${Cyan}${INDENT}Create default user${NC}${SPACER}"
    ckan -c /srv/app/ckan/registry.ini user add user_local email=temp+user@tbs-sct.gc.ca password=1234
    ckan -c /srv/app/ckan/registry.ini user setpass user_local --password 1234
    ckan -c /srv/app/ckan/portal.ini user add user_local email=temp+user@tbs-sct.gc.ca password=1234
    ckan -c /srv/app/ckan/portal.ini user setpass user_local --password 1234

    # create system admin
    printf "${SPACER}${Cyan}${INDENT}Create system admin user${NC}${SPACER}"
    ckan -c /srv/app/ckan/registry.ini user add admin_local email=temp@tbs-sct.gc.ca password=1234
    ckan -c /srv/app/ckan/registry.ini user setpass admin_local --password 1234
    ckan -c /srv/app/ckan/registry.ini sysadmin add admin_local password=1234 email=temp@tbs-sct.gc.ca
    ckan -c /srv/app/ckan/portal.ini user add admin_local email=temp@tbs-sct.gc.ca password=1234
    ckan -c /srv/app/ckan/portal.ini user setpass admin_local --password 1234
    ckan -c /srv/app/ckan/portal.ini sysadmin add admin_local password=1234 email=temp@tbs-sct.gc.ca

    # decativate python environment
    deactivate
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
    fi

fi
# END
# Create local user
# END
