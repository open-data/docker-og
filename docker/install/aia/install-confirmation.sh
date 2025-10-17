#!/bin/bash

#
# Confirm AIA repo destruction
#
if [[ $installRepos_AIA == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing AIA directory (aia)\033[0m\033[0;31m and pull fast-forwarded repositories and install them into the Node environment? [y/N]:\033[0;0m    ' response


    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installRepos_AIA='true'

    else

        installRepos_AIA='false'

    fi

fi
# END
# Confirm CKAN repo destruction
# END
