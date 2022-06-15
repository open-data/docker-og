#!/bin/bash

#
# Confirm OGC Django App rebuild
#
if [[ $installApp_Django == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want to destroy the current Django install and re-install the\033[1m Python environment and OGC code base\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installApp_Django='true'

    else

        installApp_Django='false'

    fi

fi
# END
# Confirm CKAN Datasets re-import
# END

#
# Confirm static files download
#
if [[ $installFiles_Django == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want to overwrite the\033[1m static files\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installFiles_Django='true'

    else

        installFiles_Django='false'

    fi

fi
# END
# Confirm static files download
# END