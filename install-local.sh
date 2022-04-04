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

# drupal flags
installSSH_Drupal='false'
installDB_Drupal='false'
installRepos_Drupal='false'
installFiles_Drupal='false'
installFilePermissions_Drupal='false'
installLocalUser_Drupal='false'

# ckan flags
installSSH_CKAN='false'
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

# django flags
installSSH_Django='false'
installApp_Django='false'
installFiles_Django='false'
installFilePermissions_Django='false'

# general flags
exitScript='false'

# END
# Variables
# END

#
# Install Drupal
#
function install_drupal {

  printf "${SPACER}${Cyan}${INDENT}Select what to install for ${BOLD}Drupal:${HAIR}${NC}${SPACER}"

  # Options for the user to select from
  options=(
    "SSH (Required for Repositories)" 
    "Database" 
    "Repositories" 
    "Local Files" 
    "Set File Permissions (also creates missing directories)" 
    "Create Local User"
    "All" 
    "Exit"
  )

  # IMPORTANT: select_option will return the index of the options and not the value.
  select_option "${options[@]}"
  opt=$?

  case $opt in

    # "SSH (Required for Repositories)"
    (0) 
      exitScript='false'
      installSSH_Drupal='true'
      ;;

    # "Database"
    (1) 
      exitScript='false'
      installDB_Drupal='true'
      ;;

    # "Repositories"
    (2) 
      exitScript='false'
      installRepos_Drupal='true'
      ;;

    # "Local Files"
    (3)
      exitScript='false'
      installFiles_Drupal='true'
      ;;

    # "Set File Permissions (also creates missing directories)"
    (4)
      exitScript='false'
      installFilePermissions_Drupal='true'
      ;;

    # "Create Local User"
    (5)
      exitScript='false'
      installLocalUser_Drupal='true'
      ;;

    # "All"
    (6) 
      exitScript='false'
      installSSH_Drupal='true'
      installDB_Drupal='true'
      installRepos_Drupal='true'
      installFiles_Drupal='true'
      installFilePermissions_Drupal='true'
      installLocalUser_Drupal='true'
      ;;

    # "Exit"
    (7)
      exitScript='true'
      ;;

  esac

  #
  # Run Script
  #
  if [[ $exitScript != "true" ]]; then

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

    #
    # Install and configure SSH and Agent
    #
    if [[ $installSSH_Drupal == "true" ]]; then

      # install SSH
      printf "${SPACER}${Cyan}${INDENT}Install SSH for GIT use${NC}${SPACER}"
      which ssh || apt install ssh -y

      # set strict host checking to false
      printf "${SPACER}${Cyan}${INDENT}Set strict SSH host checking to false${NC}${SPACER}"
      echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set StrictHostKeyChecking to no: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set StrictHostKeyChecking to no: FAIL${NC}${EOL}"
      fi

    fi
    # END
    # Install and configure SSH and Agent
    # END

    #
    # Destroy and re-import the Drupal database
    #
    if [[ $installDB_Drupal == "true" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_drupal_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
      psql -eb --dbname=og_drupal_local --username=$PGUSER --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_drupal_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

      # import the database
      printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_drupal_local${HAIR}${NC}${SPACER}"
      pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=$PGDATABASE --username=$PGUSER ${APP_ROOT}/backup/drupal_db.pgdump

    fi
    # END
    # Destroy and re-import the Drupal database
    # END

    #
    # Pull Drupal Core repo, Drupal profile repo, and Drupal theme repo
    #
    if [[ $installRepos_Drupal == "true" ]]; then

      if [[ $installSSH_Drupal != "true" ]]; then

        # check for SSH agent
        printf "${SPACER}${Cyan}${INDENT}Check if SSH Agent is installed and configured${NC}${SPACER}"
        which ssh || apt install ssh -y

        # set strict host checking to false
        printf "${SPACER}${Cyan}${INDENT}Set strict SSH host checking to false${NC}${SPACER}"
        echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
        if [[ $? -eq 0 ]]; then
          printf "${Green}${INDENT}${INDENT}Set StrictHostKeyChecking to no: OK${NC}${EOL}"
        else
          printf "${Red}${INDENT}${INDENT}Set StrictHostKeyChecking to no: FAIL${NC}${EOL}"
        fi

      fi

      mkdir -p ${APP_ROOT}/drupal
      cd ${APP_ROOT}/drupal

      # nuke the entire folder
      printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing Drupal install${NC}${SPACER}"
      # destroy all files
      rm -rf ./*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all files: FAIL${NC}${EOL}"
      fi
      # destroy all hidden files
      rm -rf ./.??*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all hidden files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all hidden files: FAIL${NC}${EOL}"
      fi

      # pull the core site
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}OG repository${HAIR}${Cyan} from git@github.com:open-data/opengov.git${NC}${SPACER}"
      git config --global init.defaultBranch master
      # destroy the local git repo config
      rm -rf .git
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove .git: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove .git: FAIL (local repo may not exist)${NC}${EOL}"
      fi
      git init
      git config pull.ff only
      git remote add origin git@github.com:open-data/opengov.git
      git pull git@github.com:open-data/opengov.git

      # pull the profile
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}Profile repository${HAIR}${Cyan} from git@github.com:open-data/og.git${NC}${SPACER}"
      # destroy the local git repo config
      cd ${APP_ROOT}/drupal/html/profiles/og
      rm -rf .git
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove profiles/og/.git: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove profiles/og/.git: FAIL (local repo may not exist)${NC}${EOL}"
      fi
      git init
      git config pull.ff only
      git remote add origin git@github.com:open-data/og.git
      git pull git@github.com:open-data/og.git

      # pull the theme
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}Theme repository${HAIR}${Cyan} from git@github.com:open-data/gcweb_bootstrap.git${NC}${SPACER}"
      cd ${APP_ROOT}/drupal/html/themes/custom/gcweb
      # destroy the local git repo config
      rm -rf .git
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove themes/custom/gcweb/.git: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove themes/custom/gcweb/.git: FAIL (local repo may not exist)${NC}${EOL}"
      fi
      git init
      git config pull.ff only
      git remote add origin git@github.com:open-data/gcweb_bootstrap.git
      git pull git@github.com:open-data/gcweb_bootstrap.git

    fi
    # END
    # Pull Drupal Core repo, Drupal profile repo, and Drupal theme repo
    # END

    #
    # Install Local Files
    #
    if [[ $installFiles_Drupal == "true" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Extract public files from backup${NC}${SPACER}"
      # create default sites directory
      mkdir -p ${APP_ROOT}/drupal/html/sites/default
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create sites/default: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Create sites/default: FAIL (directory may already exist)${NC}${EOL}"
      fi
      # remove default files directory
      rm -rf ${APP_ROOT}/drupal/html/sites/default/files
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Removed sites/default/files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Removed sites/default/files: FAIL (directory may not exist)${NC}${EOL}"
      fi
      cd ${APP_ROOT}/drupal/html/sites/default
      tar zxvf ${APP_ROOT}/backup/drupal_files.tgz

    fi
    # END
    # Install Local Files
    # END

    #
    # Set file and directory ownership and permissions
    #
    if [[ $installFilePermissions_Drupal == "true" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Download Drupal default settings file${NC}${SPACER}"
      cd ${APP_ROOT}/drupal/html/sites
      # remove old settings file
      rm -rf ${APP_ROOT}/drupal/html/sites/default.settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Removed sites/default.settings.php: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Removed sites/default.settings.php: FAIL (file may not exist)${NC}${EOL}"
      fi
      wget https://raw.githubusercontent.com/drupal/drupal/8.8.x/sites/default/default.settings.php
      mkdir -p ${APP_ROOT}/drupal/html/sites/default
      cd ${APP_ROOT}/drupal/html/sites/default
      # remove old settings file
      rm -rf ${APP_ROOT}/drupal/html/sites/default/default.settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Removed sites/default/default.settings.php: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Removed sites/default/default.settings.php: FAIL (file may not exist)${NC}${EOL}"
      fi
      wget https://raw.githubusercontent.com/drupal/drupal/8.8.x/sites/default/default.settings.php

      printf "${SPACER}${Cyan}${INDENT}Copy Drupal settings file${NC}${SPACER}"
      # copy docker config settings.php to drupal directory
      cp ${APP_ROOT}/drupal-local-settings.php ${APP_ROOT}/drupal/html/sites/settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied drupal-local-settings.php to sites/settings.php: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copied drupal-local-settings.php to sites/settings.php: FAIL${NC}${EOL}"
      fi
      # copy docker config settings.php to drupal directory
      cp ${APP_ROOT}/drupal-local-settings.php ${APP_ROOT}/drupal/html/sites/default/settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied drupal-local-settings.php to sites/default/settings.php: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copied drupal-local-settings.php to sites/default/settings.php: FAIL${NC}${EOL}"
      fi

      printf "${SPACER}${Cyan}${INDENT}Copy Drupal services file${NC}${SPACER}"
      # copy docker config development.services.yml to drupal directory
      cp ${APP_ROOT}/drupal-services.yml ${APP_ROOT}/drupal/html/sites/development.services.yml
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied drupal-services.yml to sites/development.services.yml: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copied drupal-services.yml to sites/development.services.yml: FAIL${NC}${EOL}"
      fi
      # copy docker config development.services.yml to drupal directory
      cp ${APP_ROOT}/drupal-services.yml ${APP_ROOT}/drupal/html/sites/default/development.services.yml
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied drupal-services.yml to sites/default/development.services.yml: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copied drupal-services.yml to sites/default/development.services.yml: FAIL${NC}${EOL}"
      fi

      printf "${SPACER}${Cyan}${INDENT}Set Drupal settings file permissions${NC}${SPACER}"
      # set file permissions for settings file
      chmod 644 ${APP_ROOT}/drupal/html/sites/settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/settings.php perms to 644: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/settings.php perms to 644: FAIL${NC}${EOL}"
      fi
      # set file permissions for default settings file
      chmod 644 ${APP_ROOT}/drupal/html/sites/default.settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default.settings.php perms to 644: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/default.settings.php to 644: FAIL${NC}${EOL}"
      fi
      # set file permissions for settings file
      chmod 644 ${APP_ROOT}/drupal/html/sites/default/settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/settings.php perms to 644: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/default/settings.php perms to 644: FAIL${NC}${EOL}"
      fi
      # set file permissions for default settings file
      chmod 644 ${APP_ROOT}/drupal/html/sites/default/default.settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/default.settings.php perms to 644: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/default/default.settings.php perms to 644: FAIL${NC}${EOL}"
      fi

      printf "${SPACER}${Cyan}${INDENT}Create config sync directory${NC}${SPACER}"
      # create drupal config sync directory
      mkdir -p ${APP_ROOT}/drupal/html/sites/default/sync
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create sites/default/sync: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Create sites/default/sync: FAIL (directory may already exist)${NC}${EOL}"
      fi

      printf "${SPACER}${Cyan}${INDENT}Create private files directory${NC}${SPACER}"
      #create private files directory
      mkdir -p ${APP_ROOT}/drupal/html/sites/default/private-files
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create sites/default/private-files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Create sites/default/private-files: FAIL (directory may already exist)${NC}${EOL}"
      fi
      # add htaccess file
      echo "Deny from all" > ${APP_ROOT}/drupal/html/sites/default/private-files/.htaccess
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Added Deny from all to private files directory: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Added Deny from all to private files directory: FAIL${NC}${EOL}"
      fi
      # set file permissions of new htaccess file
      chmod 644 ${APP_ROOT}/drupal/html/sites/default/private-files/.htaccess
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set private directory htaccess perms to 644: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set private directory htaccess perms to 644: FAIL${NC}${EOL}"
      fi

      printf "${SPACER}${Cyan}${INDENT}Set public files permissions${NC}${SPACER}"
      # set file permissions of public files directory
      chmod 755 ${APP_ROOT}/drupal/html/sites/default/files
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/files perms to 755: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/default/files perms to 755: FAIL${NC}${EOL}"
      fi

      # set file permissions of public files inner directories
      find ${APP_ROOT}/drupal/html/sites/default/files -type d -exec chmod 755 {} \;
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/files inner directory perms to 755: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/default/files inner directory perms to 755: FAIL${NC}${EOL}"
      fi

      # set file permissions of public files inner files
      find ${APP_ROOT}/drupal/html/sites/default/files -type f -exec chmod 644 {} \;
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/files inner files perms to 644: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/default/files inner files perms to 644: FAIL${NC}${EOL}"
      fi

      printf "${SPACER}${Cyan}${INDENT}Set Drupal file ownership${NC}${SPACER}"
      # set file system ownership for the drupal directory
      chown www-data:www-data -R ${APP_ROOT}/drupal
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set file system ownership to www-data: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set file system ownership to www-data: FAIL${NC}${EOL}"
      fi

    fi
    # END
    # Set file and directory ownership and permissions
    # END

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

    #
    # Update Drupal DB and clear Drupal cache
    #
    if [[ -x "$(command -v drush)" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Perform database updates${NC}${SPACER}"
      drush updb --yes

      printf "${SPACER}${Cyan}${INDENT}Clear Drupal caches${NC}${SPACER}"
      drush cr

    fi
    # END
    # Update Drupal DB and clear Drupal cache
    # END

    printf "${SPACER}${Green}${INDENT}Run me: ${BOLD}https://open.local${HAIR}${NC}${SPACER}"

  else

    printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

  fi
  # END
  # Run Script
  # END

}
# END
# Install Drupal
# END

#
# Install CKAN
#
function install_ckan {

  printf "${SPACER}${Cyan}${INDENT}Select what to install for ${BOLD}CKAN:${HAIR}${NC}${SPACER}"

  if [[ $CKAN_ROLE == 'registry' ]]; then

    # Options for the user to select from
    options=(
      "SSH (Required for Repositories)" 
      "Registry Database" 
      "Registry Datastore Database" 
      "Repositories (Installs them into Python venv ckan/${CKAN_ROLE})" 
      "Download Wet-Boew Files" 
      "Set File Permissions" 
      "Create Local User" 
      "Import Organizations" 
      "Import Datasets" 
      "All" 
      "Exit"
    )

  elif [[ $CKAN_ROLE == 'portal' ]]; then

    # Options for the user to select from
    options=(
      "SSH (Required for Repositories)" 
      "Portal Database" 
      "Portal Datastore Database" 
      "Repositories (Installs them into Python venv ckan/${CKAN_ROLE})" 
      "Download Wet-Boew Files" 
      "Set File Permissions" 
      "Create Local User" 
      "Import Organizations" 
      "Import Datasets" 
      "All" 
      "Exit"
    )

  fi

  # IMPORTANT: select_option will return the index of the options and not the value.
  select_option "${options[@]}"
  opt=$?

  case $opt in

    # "SSH (Required for Repositories)"
    (0) 
      exitScript='false'
      installSSH_CKAN='true'
      ;;

    # "Registry Database / Portal Database"
    (1) 
      exitScript='false'
      if [[ $CKAN_ROLE == 'registry' ]]; then
        installDB_Registry_CKAN='true'
        installDB_Portal_CKAN='false'
      elif [[ $CKAN_ROLE == 'portal' ]]; then
        installDB_Portal_CKAN='true'
        installDB_Registry_CKAN='false'
      fi
      ;;

    # "Registry Datastore Database / Portal Datastore Database"
    (2) 
      exitScript='false'
      if [[ $CKAN_ROLE == 'registry' ]]; then
        installDB_Registry_DS_CKAN='true'
        installDB_Portal_DS_CKAN='false'
      elif [[ $CKAN_ROLE == 'portal' ]]; then
        installDB_Portal_DS_CKAN='true'
        installDB_Registry_DS_CKAN='false'
      fi
      ;;

    # "Repositories (Installs them into Python venv)"
    (3) 
      exitScript='false'
      installRepos_CKAN='true'
      ;;

    # "Download Wet-Boew Files"
    (4)
      exitScript='false'
      installTheme_CKAN='true'
      ;;


    # "Set File Permissions"
    (5)
      exitScript='false'
      installFilePermissions_CKAN='true'
      ;;

    # "Create Local User"
    (6)
      exitScript='false'
      installLocalUser_CKAN='true'
      ;;

    # "Import Organizations"
    (7)
      exitScript='false'
      installOrgs_CKAN='true'
      ;;

    # "Import Datasets"
    (8)
      exitScript='false'
      installDatasets_CKAN='true'
      ;;

    # "All"
    (9) 
      exitScript='false'
      installSSH_CKAN='true'
      if [[ $CKAN_ROLE == 'registry' ]]; then
        installDB_Registry_CKAN='true'
        installDB_Registry_DS_CKAN='true'
        installDB_Portal_CKAN='false'
        installDB_Portal_DS_CKAN='false'
      elif [[ $CKAN_ROLE == 'portal' ]]; then
        installDB_Portal_CKAN='true'
        installDB_Portal_DS_CKAN='true'
        installDB_Registry_CKAN='false'
        installDB_Registry_DS_CKAN='false'
      fi
      installRepos_CKAN='true'
      installFilePermissions_CKAN='true'
      installLocalUser_CKAN='true'
      installOrgs_CKAN='true'
      installDatasets_CKAN='true'
      ;;

    # "Exit"
    (10)
      exitScript='true'
      ;;

  esac

  #
  # Run Script
  #
  if [[ $exitScript != "true" ]]; then

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

      if [[ $CKAN_ROLE == 'registry' ]]; then
        
        read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Registry directory (ckan/registry)\033[0m\033[0;31m and pull fast-forwarded repositories and install them into the Python environment? [y/N]:\033[0;0m    ' response

      elif [[ $CKAN_ROLE == 'portal' ]]; then
        
        read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Portaly directory (ckan/portal)\033[0m\033[0;31m and pull fast-forwarded repositories and install them into the Python environment? [y/N]:\033[0;0m    ' response
        
      fi

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

    #
    # Install and configure SSH and Agent
    #
    if [[ $installSSH_CKAN == "true" ]]; then

      # install SSH
      printf "${SPACER}${Cyan}${INDENT}Install SSH for GIT use${NC}${SPACER}"
      which ssh || apt install ssh -y

      # set strict host checking to false
      printf "${SPACER}${Cyan}${INDENT}Set strict SSH host checking to false${NC}${SPACER}"
      echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set StrictHostKeyChecking to no: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set StrictHostKeyChecking to no: FAIL${NC}${EOL}"
      fi

    fi
    # END
    # Install and configure SSH and Agent
    # END

    #
    # Destroy and re-import portal database
    #
    if [[ $installDB_Portal_CKAN == "true" ]]; then

      if [[ -f "${APP_ROOT}/backup/ckan_portal_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_portal_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_portal_local --username=$PGUSER --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_portal_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_portal_local${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_portal_local --username=$PGUSER ${APP_ROOT}/backup/ckan_portal_db.pgdump

      else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_portal_local DB${HAIR}${Orange} import, backup/ckan_portal_db.pgdump does not exist.${NC}${SPACER}"

      fi

    fi
    # END
    # Destroy and re-import portal database
    # END

    #
    # Destroy and re-import portal datastore database
    #
    if [[ $installDB_Portal_DS_CKAN == "true" ]]; then

      if [[ -f "${APP_ROOT}/backup/ckan_portal_ds_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_portal_ds_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_portal_ds_local --username=$PGUSER --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_portal_ds_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_portal_ds_local${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_portal_ds_local --username=$PGUSER ${APP_ROOT}/backup/ckan_portal_ds_db.pgdump

      else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_portal_ds_local DB${HAIR}${Orange} import, backup/ckan_portal_ds_db.pgdump does not exist.${NC}${SPACER}"

      fi

    fi
    # END
    # Destroy and re-import portal datastore database
    # END

    #
    # Destroy and re-import registry database
    #
    if [[ $installDB_Registry_CKAN == "true" ]]; then

      if [[ -f "${APP_ROOT}/backup/ckan_registry_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_registry_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_registry_local --username=$PGUSER --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_registry_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_registry_local${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_registry_local --username=$PGUSER ${APP_ROOT}/backup/ckan_registry_db.pgdump

      else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_registry_local DB${HAIR}${Orange} import, backup/ckan_registry_db.pgdump does not exist.${NC}${SPACER}"

      fi

    fi
    # END
    # Destroy and re-import registry database
    # END

    #
    # Destroy and re-import registry datastore database
    #
    if [[ $installDB_Registry_DS_CKAN == "true" ]]; then

      if [[ -f "${APP_ROOT}/backup/ckan_registry_ds_db.pgdump" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_registry_ds_local DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
        psql -eb --dbname=og_ckan_registry_ds_local --username=$PGUSER --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_registry_ds_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

        # import the database
        printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_registry_ds_local${HAIR}${NC}${SPACER}"
        pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_registry_ds_local --username=$PGUSER ${APP_ROOT}/backup/ckan_registry_ds_db.pgdump

      else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_registry_ds_local DB${HAIR}${Orange} import, backup/ckan_registry_ds_db.pgdump does not exist.${NC}${SPACER}"

      fi

    fi
    # END
    # Destroy and re-import registry datastore database
    # END

    #
    # Destroy and pull and install fast-forwarded repositories
    #
    if [[ $installRepos_CKAN == "true" ]]; then

      if [[ $installSSH_CKAN != "true" ]]; then

        # install SSH
        printf "${SPACER}${Cyan}${INDENT}Install SSH for GIT use${NC}${SPACER}"
        which ssh || apt install ssh -y

        # set strict host checking to false
        printf "${SPACER}${Cyan}${INDENT}Set strict SSH host checking to false${NC}${SPACER}"
        echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
        if [[ $? -eq 0 ]]; then
          printf "${Green}${INDENT}${INDENT}Set StrictHostKeyChecking to no: OK${NC}${EOL}"
        else
          printf "${Red}${INDENT}${INDENT}Set StrictHostKeyChecking to no: FAIL${NC}${EOL}"
        fi

      fi

      mkdir -p ${APP_ROOT}/ckan/${CKAN_ROLE}

      # nuke the entire folder
      printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing CKAN (${CKAN_ROLE}) install${NC}${SPACER}"
      # destroy all files
      cd ${APP_ROOT}/ckan/${CKAN_ROLE}
      rm -rf ./*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all files in ckan/${CKAN_ROLE}: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all files in ckan/${CKAN_ROLE}: FAIL${NC}${EOL}"
      fi
      cd ${APP_ROOT}/ckan/${CKAN_ROLE}
      rm -rf ./.??*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all hidden files in ckan/${CKAN_ROLE}: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all hidden files in ckan/${CKAN_ROLE}: FAIL${NC}${EOL}"
      fi

      # create virtual environment
      virtualenv --python=python2 ${APP_ROOT}/ckan/${CKAN_ROLE}
      cd ${APP_ROOT}/ckan/${CKAN_ROLE}

      # set ownership
      chown ckan:ckan -R ${APP_ROOT}/ckan/${CKAN_ROLE}
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: FAIL${NC}${EOL}"
      fi

      # activate python environment
      . ${APP_ROOT}/ckan/${CKAN_ROLE}/bin/activate
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Activate Python environment: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Activate Python environment: FAIL${NC}${EOL}"
      fi
      # install setup tools
      pip install setuptools==${SETUP_TOOLS_VERSION}
      # update pip
      pip install --upgrade pip==${PIP_VERSION}
      # install uwsgi
      pip install uwsgi
      # install future
      pip install future==0.18.2
      # set github as a trusted host
      ssh -T git@github.com
      # update certifi
      pip install --upgrade certifi
      # copy CA root pem chain
      cp /etc/ssl/mkcert/rootCA.pem ${APP_ROOT}/ckan/${CKAN_ROLE}/lib/python${PY_VERSION}/site-packages/certifi/cacert.pem
      # install correct version of cryptography
      pip install cryptography==2.2.2

      # install ckan core into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Core repository${HAIR}${Cyan} from git@github.com:open-data/ckan.git@canada-v2.8 and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/ckan.git@canada-v2.8#egg=ckan' -r 'https://raw.githubusercontent.com/open-data/ckan/canada-v2.8/requirements.txt' -r 'https://raw.githubusercontent.com/open-data/ckan/canada-v2.8/dev-requirements.txt'

      # install ckanapi into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN API repository${HAIR}${Cyan} from git@github.com:ckan/ckanapi.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/ckan/ckanapi.git#egg=ckanapi' -r 'https://raw.githubusercontent.com/ckan/ckanapi/master/requirements.txt'

      # install ckan canada into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Canada repository${HAIR}${Cyan} from git@github.com:open-data/ckanext-canada.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/ckanext-canada.git#egg=ckanext-canada' -r 'https://raw.githubusercontent.com/open-data/ckanext-canada/master/requirements.txt'

      # install ckan cloud storage into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Cloud Storage repository${HAIR}${Cyan} from git@github.com:open-data/ckanext-cloudstorage.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/ckanext-cloudstorage.git#egg=ckanext-cloudstorage'

      # install ckan dcat into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN DCat repository${HAIR}${Cyan} from git@github.com:open-data/ckanext-dcat.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/ckanext-dcat.git#egg=ckanext-dcat' -r 'https://raw.githubusercontent.com/open-data/ckanext-dcat/master/requirements.txt'

      # install ckan extended activity into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Extended Activity${HAIR}${Cyan} repository from git@github.com:open-data/ckanext-extendedactivity.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/ckanext-extendedactivity.git#egg=ckanext-extendedactivity'

      # install ckan extractor into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Extractor repository${HAIR}${Cyan} from git@github.com:open-data/ckanext-extractor.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/ckanext-extractor.git#egg=ckanext-extractor' -r 'https://raw.githubusercontent.com/open-data/ckanext-extractor/master/requirements.txt'

      # install ckan fluent into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Fluent repository${HAIR}${Cyan} from git@github.com:ckan/ckanext-fluent.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/ckan/ckanext-fluent.git#egg=ckanext-fluent' -r 'https://raw.githubusercontent.com/ckan/ckanext-fluent/master/requirements.txt'

      # install ckan recombinant into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Recombinant repository${HAIR}${Cyan} from git@github.com:open-data/ckanext-recombinant.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/ckanext-recombinant.git#egg=ckanext-recombinant' -r 'https://raw.githubusercontent.com/open-data/ckanext-recombinant/master/requirements.txt'

      # install ckan scheming into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Scheming repository${HAIR}${Cyan} from git@github.com:ckan/ckanext-scheming.git@composite and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/ckan/ckanext-scheming.git@composite#egg=ckanext-scheming'

      # install ckan security into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Security repository${HAIR}${Cyan} from git@github.com:open-data/ckanext-security@canada-v2.8.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/ckanext-security.git@canada-v2.8#egg=ckanext-security'

      # install ckan validation into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Validation repository${HAIR}${Cyan} from git@github.com:open-data/ckanext-validation.git@canada and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/ckanext-validation.git@canada#egg=ckanext-validation' -r 'https://raw.githubusercontent.com/open-data/ckanext-validation/canada/requirements.txt' -r 'https://raw.githubusercontent.com/open-data/ckanext-validation/canada/dev-requirements.txt'

      # install ckan xloader into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Xloader repository${HAIR}${Cyan} from git@github.com:open-data/ckanext-xloader.git@canada-v2.8  and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/ckanext-xloader.git@canada-v2.8#egg=ckanext-xloader' -r 'https://raw.githubusercontent.com/open-data/ckanext-xloader/canada-v2.8/requirements.txt' -r 'https://raw.githubusercontent.com/open-data/ckanext-xloader/canada-v2.8/dev-requirements.txt'

      # install ckantoolkit into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Toolkit repository${HAIR}${Cyan} from git@github.com:ckan/ckantoolkit.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/ckan/ckantoolkit.git#egg=ckantoolkit' -r 'https://raw.githubusercontent.com/ckan/ckantoolkit/master/requirements.txt'

      # install goodtables into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}Goodtables repository${HAIR}${Cyan} from git@github.com:open-data/goodtables.git@canada and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/goodtables.git@canada#egg=goodtables' -r 'https://raw.githubusercontent.com/open-data/goodtables/canada/requirements.txt'

      # install ckan wet boew into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Wet-Boew repository${HAIR}${Cyan} from git@github.com:open-data/ckanext-wet-boew.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/ckanext-wet-boew.git#egg=ckanext-wet-boew' -r 'https://raw.githubusercontent.com/open-data/ckanext-wet-boew/master/requirements.txt'

      # install flask admin
      pip install Flask-Admin==1.4.0

      # install flask login
      pip install Flask-Login==0.3.0

      # install flask sql alchemy
      pip install Flask-SQLAlchemy==2.5.1

      # install correct version of slugify
      pip install python-slugify==1.2.0

      # install request with security modules
      pip install requests[security]==2.11.1

      # install correct version of cryptography
      pip install cryptography==2.2.2

      # copy local ckan config file
      cp ${APP_ROOT}/${CKAN_ROLE}.ini ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini
      printf "${SPACER}${Cyan}${INDENT}Copying local ${CKAN_ROLE} config file to into Python environment${NC}${SPACER}"
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ${CKAN_ROLE}.ini to ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ${CKAN_ROLE}.ini to ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini: FAIL${NC}${EOL}"
      fi

      # copy core who config file
      cp ${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckan/ckan/config/who.ini ${APP_ROOT}/ckan/${CKAN_ROLE}/who.ini
      printf "${SPACER}${Cyan}${INDENT}Copying Core CKAN who config file to into root Python environment${NC}${SPACER}"
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ckan/${CKAN_ROLE}/src/ckan/ckan/config/who.ini to ckan/${CKAN_ROLE}/who.ini: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ckan/${CKAN_ROLE}/src/ckan/ckan/config/who.ini to ckan/${CKAN_ROLE}/who.ini: FAIL${NC}${EOL}"
      fi

      # create i18n directory
      mkdir -p /srv/app/ckan/${CKAN_ROLE}/src/ckanext-canada/build
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create /srv/app/ckan/${CKAN_ROLE}/src/ckanext-canada/build: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Create /srv/app/ckan/${CKAN_ROLE}/src/ckanext-canada/build: FAIL (directory may already exist)${NC}${EOL}"
      fi

      # generate translation files
      cd /srv/app/ckan/${CKAN_ROLE}/src/ckanext-canada/bin
      . build-combined-ckan-mo.sh

      # decativate python environment
      deactivate
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
      fi

      # create storage path
      printf "${SPACER}${Cyan}${INDENT}Create storage path${NC}${SPACER}"
      mkdir -p ${APP_ROOT}/ckan/${CKAN_ROLE}/storage
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create ckan/${CKAN_ROLE}/storage: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Create ckan/${CKAN_ROLE}/storage: FAIL (directory may already exist)${NC}${EOL}"
      fi

      # copy ckanext-canada static files to static_files
      printf "${SPACER}${Cyan}${INDENT}Copy CKAN Canada static files${NC}${SPACER}"
      cp -R ${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/static ${APP_ROOT}/ckan/static_files/
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/static to ${APP_ROOT}/ckan/static_files/static: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/static to ${APP_ROOT}/ckan/static_files/statice: FAIL${NC}${EOL}"
      fi
      chown -R ckan:ckan ${APP_ROOT}/ckan/static_files

      # copy wsgi files
      printf "${SPACER}${Cyan}${INDENT}Copy ${CKAN_ROLE} wsgi config file to virtual environment${NC}${SPACER}"
      cp ${APP_ROOT}/docker/config/ckan/wsgi/${CKAN_ROLE}.py ${APP_ROOT}/ckan/${CKAN_ROLE}/wsgi.py
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ${APP_ROOT}/docker/config/ckan/wsgi/${CKAN_ROLE}.py to ${APP_ROOT}/ckan/${CKAN_ROLE}/wsgi.py: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ${APP_ROOT}/docker/config/ckan/wsgi/${CKAN_ROLE}.py to ${APP_ROOT}/ckan/${CKAN_ROLE}/wsgi.py: FAIL${NC}${EOL}"
      fi

      # set ownership
      chown ckan:ckan -R ${APP_ROOT}/ckan/${CKAN_ROLE}
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: FAIL${NC}${EOL}"
      fi

    fi
    # END
    # Destroy and pull and install fast-forwarded repositories
    # END

    #
    # Download Wet-Boew repo archives for CKAN
    #
    if [[ $installTheme_CKAN == "true" ]]; then

      mkdir -p ${APP_ROOT}/ckan/static_files
      cd ${APP_ROOT}/ckan/static_files

      # nuke the entire folder
      printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing CKAN Static Files directory${NC}${SPACER}"
      # destroy all files
      rm -rf ./*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all files: FAIL${NC}${EOL}"
      fi
      # destroy all hidden files
      rm -rf ./.??*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all hidden files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all hidden files: FAIL${NC}${EOL}"
      fi

      # download wet-boew/wet-boew-cdn
      mkdir -p ${APP_ROOT}/ckan/static_files/wet-boew
      curl -L https://github.com/wet-boew/wet-boew-cdn/archive/${WET_VERSION}.tar.gz | tar -zvx --strip-components 1 --directory=${APP_ROOT}/ckan/static_files/wet-boew

      # download wet-boew/themes-cdn
      mkdir -p ${APP_ROOT}/ckan/static_files/GCWeb
      curl -L https://github.com/wet-boew/themes-cdn/archive/${GCWEB_VERSION}-gcweb.tar.gz | tar -zvx --strip-components 1 --directory=${APP_ROOT}/ckan/static_files/GCWeb

    fi
    # END
    # Pull Wet-Boew repos for CKAN
    # END

    #
    # Set file permissions
    #
    if [[ $installFilePermissions_CKAN == "true" ]]; then

      # set file ownership for ckan files
      chown ckan:ckan -R ${APP_ROOT}/ckan/${CKAN_ROLE}
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: FAIL${NC}${EOL}"
      fi

      # set file ownership for ckan static files
      chown ckan:ckan -R ${APP_ROOT}/ckan/static_files
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set ckan/static_files ownership to ckan:ckan: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set ckan/static_files ownership to ckan:ckan: FAIL${NC}${EOL}"
      fi

      # set database permissions
      paster --plugin=ckan datastore set-permissions -c ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini | psql -U homestead --set ON_ERROR_STOP=1

    fi
    # END
    # Set file permissions
    # END

    #
    # Create local user
    #
    if [[ $installLocalUser_CKAN == "true" ]]; then

      if [[ $CKAN_ROLE == 'registry' ]]; then

        # create member user
        printf "${SPACER}${Cyan}${INDENT}Create default user${NC}${SPACER}"
        paster --plugin=ckan user add user_local email=temp+user@tbs-sct.gc.ca password=12345678 -c $REGISTRY_CONFIG

        # create system admin
        printf "${SPACER}${Cyan}${INDENT}Create system admin user${NC}${SPACER}"
        paster --plugin=ckan sysadmin -c $REGISTRY_CONFIG -v add admin_local password=12345678 email=temp@tbs-sct.gc.ca

      elif [[ $CKAN_ROLE == 'portal' ]]; then

        # create member user
        printf "${SPACER}${Cyan}${INDENT}Create default user${NC}${SPACER}"
        paster --plugin=ckan user add user_local email=temp+user@tbs-sct.gc.ca password=12345678 -c $PORTAL_CONFIG

        # create system admin
        printf "${SPACER}${Cyan}${INDENT}Create system admin user${NC}${SPACER}"
        paster --plugin=ckan sysadmin -c $PORTAL_CONFIG -v add admin_local password=12345678 email=temp@tbs-sct.gc.ca

      fi

    fi
    # END
    # Create local user
    # END

    #
    # Import Organizations
    #
    if [[ $installOrgs_CKAN == "true" ]]; then

      # remove old orgs file
      printf "${SPACER}${Cyan}${INDENT}Remove old orgs.jsonl file${NC}${SPACER}"
      rm -rf ${APP_ROOT}/backup/orgs.jsonl

      # dump new orgs
      printf "${SPACER}${Cyan}${INDENT}Dump latest Organizations into orgs.jsonl file${NC}${SPACER}"
      ckanapi dump organizations --all -r https://open.canada.ca/data -O ${APP_ROOT}/backup/orgs.jsonl
      chown ckan:ckan ${APP_ROOT}/backup/orgs.jsonl

      # import the orgs
      printf "${SPACER}${Cyan}${INDENT}Import Organizations${NC}${SPACER}"
      ckanapi load organizations -I ${APP_ROOT}/backup/orgs.jsonl -c ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini

    fi
    # END
    # Import Organizations
    # END

    #
    # Import Datasets
    #
    if [[ $installDatasets_CKAN == "true" ]]; then

      # remove old datasets file
      printf "${SPACER}${Cyan}${INDENT}Remove old Datasets file${NC}${SPACER}"
      rm -rf ${APP_ROOT}/backup/od-do-canada.jsonl.gz

      # download new datasets
      printf "${SPACER}${Cyan}${INDENT}Download new Datasets file${NC}${SPACER}"
      curl --output ${APP_ROOT}/backup/od-do-canada.jsonl.gz https://open.canada.ca/static/od-do-canada.jsonl.gz
      chown ckan:ckan ${APP_ROOT}/backup/od-do-canada.jsonl.gz

      # import the datasets
      printf "${SPACER}${Cyan}${INDENT}Import Datasets${NC}${SPACER}"
      ckanapi load datasets -I ${APP_ROOT}/backup/od-do-canada.jsonl.gz -z -p 16 -c ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini

    fi
    # END
    # Import Datasets
    # END

  else

    printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

  fi
  # END
  # Run Script
  # END

}
# END
# Install CKAN
# END

#
# Install Django
#
function install_django {

  printf "${SPACER}${Cyan}${INDENT}Select what to install for ${BOLD}Django:${HAIR}${NC}${SPACER}"

  # Options for the user to select from
  options=(
    "SSH (Required for Repositories)" 
    "OGC Django Search App" 
    "Static Files" 
    "Set File Permissions" 
    "All" 
    "Exit"
  )

  # IMPORTANT: select_option will return the index of the options and not the value.
  select_option "${options[@]}"
  opt=$?

  case $opt in

    # "SSH (Required for Repositories)"
    (0) 
      exitScript='false'
      installSSH_Django='true'
      ;;

    # "OGC Django Search App"
    (1) 
      exitScript='false'
      installApp_Django='true'
      ;;

    # "Static Files"
    (2) 
      exitScript='false'
      installFiles_Django='true'
      ;;

    # "Set File Permissions"
    (3)
      exitScript='false'
      installFilePermissions_Django='true'
      ;;

    # "All"
    (4)
      exitScript='false'
      installSSH_Django='true'
      installApp_Django='true'
      installFiles_Django='true'
      installFilePermissions_Django='true'
      ;;

    # "Exit"
    (5)
      exitScript='true'
      ;;

  esac

  #
  # Run Script
  #
  if [[ $exitScript != "true" ]]; then

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

    #
    # Install SSH for git use
    #
    if [[ $installSSH_Django == "true" ]]; then

      # install SSH
      printf "${SPACER}${Cyan}${INDENT}Install SSH for GIT use${NC}${SPACER}"
      which ssh || apt install ssh -y

      # set strict host checking to false
      printf "${SPACER}${Cyan}${INDENT}Set strict SSH host checking to false${NC}${SPACER}"
      echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set StrictHostKeyChecking to no: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set StrictHostKeyChecking to no: FAIL${NC}${EOL}"
      fi

    fi
    # END
    # Install SSH for git use
    # END

    #
    # Install OGC Django App
    #
    if [[ $installApp_Django == "true" ]]; then

      if [[ $installSSH_Django == "false" ]]; then

        # install SSH
        printf "${SPACER}${Cyan}${INDENT}Install SSH for GIT use${NC}${SPACER}"
        which ssh || apt install ssh -y

        # set strict host checking to false
        printf "${SPACER}${Cyan}${INDENT}Set strict SSH host checking to false${NC}${SPACER}"
        echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
        if [[ $? -eq 0 ]]; then
          printf "${Green}${INDENT}${INDENT}Set StrictHostKeyChecking to no: OK${NC}${EOL}"
        else
          printf "${Red}${INDENT}${INDENT}Set StrictHostKeyChecking to no: FAIL${NC}${EOL}"
        fi

      fi

      mkdir -p ${APP_ROOT}/django

      # nuke the entire folder
      printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing Django install${NC}${SPACER}"
      # destroy all files
      cd ${APP_ROOT}/django
      rm -rf ./*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all files in django: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all files in django: FAIL${NC}${EOL}"
      fi
      cd ${APP_ROOT}/django
      rm -rf ./.??*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all hidden files in django: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all hidden files in django: FAIL${NC}${EOL}"
      fi

      # create virtual environment
      python3 -m venv ${APP_ROOT}/django
      cd ${APP_ROOT}/django

      # set ownership
      chown django:django -R ${APP_ROOT}/django
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set django ownership to django:django: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set django ownership to django:django: FAIL${NC}${EOL}"
      fi

      # activate python environment
      . ${APP_ROOT}/django/bin/activate
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Activate Python environment: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Activate Python environment: FAIL${NC}${EOL}"
      fi

      # install setup tools
      pip install --upgrade setuptools
      pip install --upgrade setuptools_rust
      pip install --upgrade rust
      # install wheel
      pip install wheel
      # install py solr
      pip install pysolr
      # set github as a trusted host
      ssh -T git@github.com
      # update certifi
      pip install --upgrade certifi
      # copy CA root pem chain
      cp /etc/ssl/mkcert/rootCA.pem ${APP_ROOT}/django/lib/python${PY_VERSION}/site-packages/certifi/cacert.pem
      # install correct version of cryptography
      pip install cryptography==2.2.2

      # install ogc search into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}OGC Search repository${HAIR}${Cyan} from git@github.com:open-data/ogc_search.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+ssh://git@github.com/open-data/ogc_search.git#egg=ogc_search' -r 'https://raw.githubusercontent.com/open-data/ogc_search/master/requirements.txt'

      # install request with security modules
      pip install requests[security]==2.27.1

      # install correct version of cryptography
      pip install cryptography==2.2.2

      # decativate python environment
      deactivate
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
      fi

      # copy local search settings file
      printf "${SPACER}${Cyan}${INDENT}Copy django config file to virtual environment${NC}${SPACER}"
      cp ${APP_ROOT}/search-settings.py ${APP_ROOT}/django/src/ogc-search/ogc_search/ogc_search/settings.py
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ${APP_ROOT}/search-settings.py to ${APP_ROOT}/django/src/ogc_search/ogc_search/settings.py: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ${APP_ROOT}/search-settings.py to ${APP_ROOT}/django/src/ogc_search/ogc_search/settings.py: FAIL${NC}${EOL}"
      fi

      # download yaml config files
      printf "${SPACER}${Cyan}${INDENT}Download CKAN config files${NC}${SPACER}"
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/ckan_config_files
      cd ${APP_ROOT}/django/src/ogc-search/ogc_search/ckan_config_files
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/schemas/presets.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/briefingt.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/contracts.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/grants.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/nap.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/qpnotes.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/service.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/choices/minister.json
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/schemas/prop.yaml

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
    # Install OGC Django App
    # END

    #
    # Download static files
    #
    if [[ $installFiles_Django == "true" ]]; then

      if [[ $installSSH_Django == "false" ]]; then

        # install SSH
        printf "${SPACER}${Cyan}${INDENT}Install SSH for GIT use${NC}${SPACER}"
        which ssh || apt install ssh -y

        # set strict host checking to false
        printf "${SPACER}${Cyan}${INDENT}Set strict SSH host checking to false${NC}${SPACER}"
        echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
        if [[ $? -eq 0 ]]; then
          printf "${Green}${INDENT}${INDENT}Set StrictHostKeyChecking to no: OK${NC}${EOL}"
        else
          printf "${Red}${INDENT}${INDENT}Set StrictHostKeyChecking to no: FAIL${NC}${EOL}"
        fi

      fi

      # download wet-boew/themes-cdn
      printf "${SPACER}${Cyan}${INDENT}Download the wet-boew theme${NC}${SPACER}"
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/themes-dist-GCWeb
      cd ${APP_ROOT}/django/src/ogc-search/ogc_search/themes-dist-GCWeb
      curl -L https://github.com/wet-boew/themes-cdn/archive/${GCWEB_VERSION}-gcweb.tar.gz | tar -zvx --strip-components 1 --directory=${APP_ROOT}/django/src/ogc-search/ogc_search/themes-dist-GCWeb

      # pull the cenw-wscoe/sgdc-cdts repo
      printf "${SPACER}${Cyan}${INDENT}Pull the CDTS repo${NC}${SPACER}"
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts/source
      cd ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts/source
      rm -rf ./*
      rm -rf ./.??*
      git init
      git config pull.ff only
      git remote add origin git@github.com:cenw-wscoe/sgdc-cdts.git
      git pull git@github.com:cenw-wscoe/sgdc-cdts.git

      # unpack the GCWeb Static release
      printf "${SPACER}${Cyan}${INDENT}Unpack the GCWeb Static release from the CDTS repo${NC}${SPACER}"
      unzip ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts/source/GCWeb/static/Gcwebstatic-${CDTS_GCWEB_VERSION}.zip -d ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts
      cd ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts/static
      mv * ../
      cd ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts
      rm -rf ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts/static

      # copy static files to static root
      printf "${SPACER}${Cyan}${INDENT}Copy static files to the static root directory${NC}${SPACER}"
      # cdts static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/cdts
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/cdts
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy CDTS static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy CDTS static files: FAIL${NC}${EOL}"
      fi
      rm -rf ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts
      # wet static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/wet
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/wet/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/wet
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy WET static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy WET static files: FAIL${NC}${EOL}"
      fi
      # open data static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/open_data
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/open_data/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/open_data
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Open Data static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Open Data static files: FAIL${NC}${EOL}"
      fi
      # ati static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/ati
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/ATI/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/ati
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ATI static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ATI static files: FAIL${NC}${EOL}"
      fi
      # briefing notes static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/bn
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/briefing_notes/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/bn
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Briefing Notes static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Briefing Notes static files: FAIL${NC}${EOL}"
      fi
      # contracts static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/ct
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/contracts/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/ct
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Contracts static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Contracts static files: FAIL${NC}${EOL}"
      fi
      # experimental inventory static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/ei
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/experimental_inventory/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/ei
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Experimental Inventory static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Experimental Inventory static files: FAIL${NC}${EOL}"
      fi
      # grant static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/gc
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/grants/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/gc
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Grants static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Grants static files: FAIL${NC}${EOL}"
      fi
      # nap static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/nap
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/national_action_plan/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/nap
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy National Action Plan static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy National Action Plan static files: FAIL${NC}${EOL}"
      fi
      # qp notes static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/qp
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/qp_notes/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/qp
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy QP Notes static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy QP Notes static files: FAIL${NC}${EOL}"
      fi
      # service inventory static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/si
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/service_inventory/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/si
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Service Inventory static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Service Inventory static files: FAIL${NC}${EOL}"
      fi
      # suggested dataset static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/sd
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/suggested_dataset/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/sd
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Suggested Dataset static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Suggested Dataset static files: FAIL${NC}${EOL}"
      fi
      # GCWeb theme
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/wxt
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/themes-dist-GCWeb/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/wxt
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy GCWeb Theme files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy GCWeb Theme files: FAIL${NC}${EOL}"
      fi
      rm -rf ${APP_ROOT}/django/src/ogc-search/ogc_search/themes-dist-GCWeb

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
    # Download static files
    # END

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

  else

    printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

  fi

}
# END
# Install Django
# END

#
# Install Databases
#
function install_databases {

  psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
    CREATE USER homestead;
    ALTER USER homestead PASSWORD 'secret';
    CREATE USER homestead_reader;
    ALTER USER homestead_reader PASSWORD 'secret';
    CREATE DATABASE og_drupal_local;
    CREATE DATABASE og_ckan_portal_local;
    CREATE DATABASE og_ckan_portal_ds_local;
    CREATE DATABASE og_ckan_registry_local;
    CREATE DATABASE og_ckan_registry_ds_local;
    GRANT ALL PRIVILEGES ON DATABASE og_drupal_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_ds_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_ds_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_drupal_local TO homestead_reader;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_local TO homestead_reader;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_portal_ds_local TO homestead_reader;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_local TO homestead_reader;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_ds_local TO homestead_reader;
EOSQL

}
# END
# Install Databases
# END

#
# Custom Select Option handling
#
# Renders a text based list of options that can be selected by the user using up, down and enter keys and returns the chosen option.
function select_option {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0

    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in

            (enter) 
              break
              ;;

            (up)    
              ((selected--));
              if [ $selected -lt 0 ]; then

                selected=$(($# - 1));

              fi
              ;;

            (down)  
              ((selected++));
              if [ $selected -ge $# ]; then 
              
                selected=0; 
                
              fi
              ;;

        esac

    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected

}
# END
# Custom Select Option handling
# END

printf "${SPACER}${Cyan}${INDENT}Select what to install:${NC}${SPACER}"

if [[ ${CONTAINER_ROLE} == "drupal" ]]; then

  # Options for the user to select from
  options=(
    "Drupal" 
    "Databases (fixes missing databases, privileges, and users)"
    "All" 
    "Exit"
  )

elif [[ ${CONTAINER_ROLE} == "ckan" ]]; then

  # Options for the user to select from
  options=(
    "CKAN (${CKAN_ROLE})"
    "Databases (fixes missing databases, privileges, and users)"
    "All" 
    "Exit"
  )

elif [[ ${CONTAINER_ROLE} == "search" ]]; then

  # Options for the user to select from
  options=(
    "Django"
    "Databases (fixes missing databases, privileges, and users)"
    "All" 
    "Exit"
  )

fi

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

  # "Drupal or CKAN or Django"
  (0) 
    if [[ ${CONTAINER_ROLE} == "drupal" ]]; then
      exitScript='false'
      installDrupal='true'
    elif [[ ${CONTAINER_ROLE} == "ckan" ]]; then
      exitScript='false'
      installCKAN='true'
    elif [[ ${CONTAINER_ROLE} == "search" ]]; then
      exitScript='false'
      installDjango='true'
    fi
    ;;

  (1)
    exitScript='false'
    installDatabases='true'
    ;;

  # "All"
  (2) 
    if [[ ${CONTAINER_ROLE} == "drupal" ]]; then
      installDrupal='true'
      installCKAN='false'
      installDjango='false'
    elif [[ ${CONTAINER_ROLE} == "ckan" ]]; then
      installCKAN='true'
      installDjango='false'
      installDrupal='false'
    elif [[ ${CONTAINER_ROLE} == "search" ]]; then
      installDjango='true'
      installCKAN='false'
      installDrupal='false'
    fi
    exitScript='false'
    installDatabases='true'
    ;;

  # "Exit"
  (3)
    exitScript='true'
    ;;

esac

#
# Run Script
#
if [[ $exitScript != "true" ]]; then

  if [[ $installDatabases == "true" ]]; then

    install_databases

  fi

  if [[ $installDrupal == "true" ]]; then

    install_drupal

  fi

  if [[ $installCKAN == "true" ]]; then

    install_ckan

  fi

  if [[ $installDjango == "true" ]]; then

    install_django

  fi

else

  printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi
# END
# Run Script
# END