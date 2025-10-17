#!/bin/bash

#
# Set file permissions
#
if [[ $installFilePermissions_AIA == "true" ]]; then

    # set file ownership for ckan files
    chown vuejs:vuejs -R ${APP_ROOT}/aia
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set aia ownership to vuejs:vuejs: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set aia ownership to vuejs:vuejs: FAIL${NC}${EOL}"
    fi

fi
# END
# Set file permissions
# END
