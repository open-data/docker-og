#!/bin/bash

#
# Create local user
#
if [[ $installLocalUser_CKAN == "true" ]]; then

    # create member user
    printf "${SPACER}${Cyan}${INDENT}Create default user${NC}${SPACER}"
    ckan -c $REGISTRY_CONFIG user add user_local email=temp+user@tbs-sct.gc.ca password=12345678

    # create system admin
    printf "${SPACER}${Cyan}${INDENT}Create system admin user${NC}${SPACER}"
    ckan -c $REGISTRY_CONFIG user add admin_local email=temp@tbs-sct.gc.ca password=12345678
    ckan -c $REGISTRY_CONFIG sysadmin add admin_local password=12345678 email=temp@tbs-sct.gc.ca

fi
# END
# Create local user
# END
