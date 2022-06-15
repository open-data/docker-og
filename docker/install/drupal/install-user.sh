#!/bin/bash

#
# Create Drupal admin user
#
if [[ $installLocalUser_Drupal == "true" ]]; then

    if [[ -x "$(command -v drush)" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Set local user admin${NC}${SPACER}"
        cd ${APP_ROOT}/drupal
        drush uinf admin.local || drush user:create admin.local --password=12345678
        drush urol administrator admin.local

    else

        printf "${SPACER}${Yellow}${INDENT}Drush command not found...skipping local Drupal user creation...${NC}${SPACER}"

    fi

fi
# END
# Create Drupal admin user
# END