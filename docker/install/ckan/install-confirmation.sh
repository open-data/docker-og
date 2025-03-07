#!/bin/bash

#
# Confirm CKAN Portal database destruction
#
if [[ $installDB_Portal_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Portal database\033[0m\033[0;31m and import a fresh copy? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installDB_Portal_CKAN='true'

    else

        installDB_Portal_CKAN='false'

    fi

fi
# END
# Confirm CKAN Portal database destruction
# END

#
# Confirm CKAN Portal Datastore database destruction
#
if [[ $installDB_Portal_DS_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Portal Datastore database\033[0m\033[0;31m and import a fresh copy? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installDB_Portal_DS_CKAN='true'

    else

        installDB_Portal_DS_CKAN='false'

    fi

fi
# END
# Confirm CKAN Portal Datastore database destruction
# END

#
# Confirm CKAN Registry database destruction
#
if [[ $installDB_Registry_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Registry database\033[0m\033[0;31m and import a fresh copy? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installDB_Registry_CKAN='true'

    else

        installDB_Registry_CKAN='false'

    fi

fi
# END
# Confirm CKAN Registry database destruction
# END

#
# Confirm CKAN Registry Datastore database destruction
#
if [[ $installDB_Registry_DS_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Registry Datastore database\033[0m\033[0;31m and import a fresh copy? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installDB_Registry_DS_CKAN='true'

    else

        installDB_Registry_DS_CKAN='false'

    fi

fi
# END
# Confirm CKAN Registry Datase database destruction
# END

#
# Confirm CKAN repo destruction
#
if [[ $installRepos_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Registry & Portal directory (ckan)\033[0m\033[0;31m and pull fast-forwarded repositories and install them into the Python environment? [y/N]:\033[0;0m    ' response


    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installRepos_CKAN='true'

    else

        installRepos_CKAN='false'

    fi

fi
# END
# Confirm CKAN repo destruction
# END

#
# Confirm CKAN Wet-Boew repo archive destruction
#
if [[ $installTheme_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Wet-Boew directory (ckan/static_files)\033[0m\033[0;31m and download new files? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installTheme_CKAN='true'

    else

        installTheme_CKAN='false'

    fi

fi
# END
# Confirm CKAN Wet-Boew repo archive destruction
# END

#
# Confirm CKAN Organizations re-import
#
if [[ $installOrgs_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want to re-import all of the\033[1m CKAN Organizations\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installOrgs_CKAN='true'

    else

        installOrgs_CKAN='false'

    fi

fi
# END
# Confirm CKAN Organizations re-import
# END

#
# Confirm CKAN Datasets re-import
#
if [[ $installDatasets_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want to re-import all of the\033[1m CKAN Datasets\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installDatasets_CKAN='true'

    else

        installDatasets_CKAN='false'

    fi

fi
# END
# Confirm CKAN Datasets re-import
# END
