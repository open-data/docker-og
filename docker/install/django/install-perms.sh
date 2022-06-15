#!/bin/bash

#
# Set ownership
#
if [[ $installFilePermissions_Django == "true" ]]; then

    # set ownership
    cd ${APP_ROOT}/django
    chown django:django -R ${APP_ROOT}/django
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set django ownership to django:django: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set django ownership to django:django: FAIL${NC}${EOL}"
    fi

fi
# END
# Set ownership
# END