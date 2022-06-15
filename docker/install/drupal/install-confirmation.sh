#!/bin/bash

#
# Confirm Drupal database destruction
#
if [[ $installDB_Drupal == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing Drupal database\033[0m\033[0;31m and import a fresh copy? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installDB_Drupal='true'

    else

        installDB_Drupal='false'

    fi

fi
# END
# Confirm Drupal database destruction
# END

#
# Confirm Drupal repo destruction
#
if [[ $installRepos_Drupal == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing Drupal directory\033[0m\033[0;31m and pull fast-forwarded repositories? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installRepos_Drupal='true'

    else

        installRepos_Drupal='false'

    fi

fi
# END
# Confirm Drupal repo destruction
# END

#
# Confirm Drupal local file destruction
#
if [[ $installFiles_Drupal == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing Drupal public files\033[0m\033[0;31m and import from the tar ball? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installFiles_Drupal='true'

    else

        installFiles_Drupal='false'

    fi

fi
# END
# Confirm Drupal local file destruction
# END