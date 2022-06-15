#!/bin/bash

#
# Variables
#

# text
Cyan='\033[0;36m'
Yellow='\033[1;33m'
Red='\033[0;31m'
Orange='\033[0;33m'
Green='\033[0;32m'
NC='\033[0;0m'
EOL='\n'
SPACER='\n\n'
INDENT='    '
BOLD='\033[1m'
HAIR='\033[0m'

# core flags
installDrupal='false'
installCKAN='false'
installDjango='false'
installDatabases='false'
installDatabaseCopies='false'

# drupal flags
installDB_Drupal='false'
installRepos_Drupal='false'
installFiles_Drupal='false'
installFilePermissions_Drupal='false'
installLocalUser_Drupal='false'

# ckan flags
installDB_Portal_CKAN='false'
installDB_Portal_DS_CKAN='false'
installDB_Registry_CKAN='false'
installDB_Registry_DS_CKAN='false'
installRepos_CKAN='false'
installTheme_CKAN='false'
installFilePermissions_CKAN='false'
installLocalUser_CKAN='false'
installOrgs_CKAN='false'
installDatasets_CKAN='false'
installInventory_CKAN='false'

# django flags
installApp_Django='false'
installFiles_Django='false'
installFilePermissions_Django='false'

# test DB flags
cloneDB_Drupal='false'
cloneDB_Portal_CKAN='false'
cloneDB_Portal_DS_CKAN='false'
cloneDB_Registry_CKAN='false'
cloneDB_Registry_DS_CKAN='false'

# general flags
exitScript='false'

# END
# Variables
# END