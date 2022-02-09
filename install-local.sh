#!/bin/bash

#
# Variables
#

# text
Cyan='\033[0;36m'
Yellow='\033[1;33m'
Red='\033[0;31m'
Green='\033[0;32m'
NC='\033[0;0m'
EOL='\n'
SPACER='\n\n'
INDENT='    '

# core flags
installDrupal='false'
installCKAN='false'
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
installDB_CKAN='false'
installDB_Registry_CKAN='false'
installDB_Registry_DS_CKAN='false'
installRepos_CKAN='false'
installFilePermissions_CKAN='false'

# general flags
exitScript='false'

# END
# Variables
# END

#
# Install Drupal
#
function install_drupal {

  printf "${SPACER}${Cyan}${INDENT}Select what to install for Drupal:${NC}${SPACER}"

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

      read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing Drupal database and import a fresh copy? [y/N]:\033[0;0m    ' response

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

      read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing Drupal directory and pull fast-forwarded repositories? [y/N]:\033[0;0m    ' response

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

      read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing Drupal public files and import from the tar ball? [y/N]:\033[0;0m    ' response

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

      printf "${SPACER}${Cyan}${INDENT}Drop the og_drupal_local DB if it exists and then recreate it blank/clean${NC}${SPACER}"
      psql -eb --dbname=og_drupal_local --username=$PGUSER --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_drupal_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

      # import the database
      printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into og_drupal_local${NC}${SPACER}"
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
      printf "${SPACER}${Cyan}${INDENT}Pulling OG repository from git@github.com:open-data/opengov.git${NC}${SPACER}"
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
      printf "${SPACER}${Cyan}${INDENT}Pulling Profile repository from git@github.com:open-data/og.git${NC}${SPACER}"
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
      printf "${SPACER}${Cyan}${INDENT}Pulling Theme repository from git@github.com:open-data/gcweb_bootstrap.git${NC}${SPACER}"
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

    printf "${SPACER}${Green}${INDENT}Run me: https://open.local${NC}${SPACER}"

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

  printf "${SPACER}${Cyan}${INDENT}Select what to install for CKAN:${NC}${SPACER}"

  # Options for the user to select from
  options=(
    "SSH (Required for Repositories)" 
    "Core Database" 
    "Registry Database" 
    "Registry Datastore Database" 
    "Repositories (Installs them into Python venv)" 
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
      installSSH_CKAN='true'
      ;;

    # "Core Database"
    (1) 
      exitScript='false'
      installDB_CKAN='true'
      ;;

    # "Registry Database"
    (2) 
      exitScript='false'
      installDB_Registry_CKAN='true'
      ;;

    # "Registry Datastore Database"
    (3) 
      exitScript='false'
      installDB_Registry_DS_CKAN='true'
      ;;

    # "Repositories (Installs them into Python venv)"
    (4) 
      exitScript='false'
      installRepos_CKAN='true'
      ;;

    # "Set File Permissions"
    (5)
      exitScript='false'
      installFilePermissions_CKAN='true'
      ;;

    # "All"
    (6) 
      exitScript='false'
      installSSH_CKAN='true'
      installDB_CKAN='true'
      installDB_Registry_CKAN='true'
      installDB_Registry_DS_CKAN='true'
      installRepos_CKAN='true'
      installFilePermissions_CKAN='true'
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
    # Confirm CKAN core database destruction
    #
    if [[ $installDB_CKAN == "true" ]]; then

      read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing CKAN Core database and import a fresh copy? [y/N]:\033[0;0m    ' response

      if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installDB_CKAN='true'

      else

        installDB_CKAN='false'

      fi

    fi
    # END
    # Confirm CKAN core database destruction
    # END

    #
    # Confirm CKAN END database destruction
    #
    if [[ $installDB_Registry_CKAN == "true" ]]; then

      read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing CKAN Registry database and import a fresh copy? [y/N]:\033[0;0m    ' response

      if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installDB_Registry_CKAN='true'

      else

        installDB_Registry_CKAN='false'

      fi

    fi
    # END
    # Confirm CKAN registry database destruction
    # END

    #
    # Confirm CKAN registry datastore database destruction
    #
    if [[ $installDB_Registry_DS_CKAN == "true" ]]; then

      read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing CKAN Registry Datastore database and import a fresh copy? [y/N]:\033[0;0m    ' response

      if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installDB_Registry_DS_CKAN='true'

      else

        installDB_Registry_DS_CKAN='false'

      fi

    fi
    # END
    # Confirm CKAN registry datastore database destruction
    # END

    #
    # Confirm CKAN repo destruction
    #
    if [[ $installRepos_CKAN == "true" ]]; then

      read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing CKAN directory and pull fast-forwarded repositories and install them into the Python environment? [y/N]:\033[0;0m    ' response

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
    # Destroy and re-import core database
    #
    if [[ $installDB_CKAN == "true" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Drop the og_ckan_local DB if it exists and then recreate it blank/clean${NC}${SPACER}"
      psql -eb --dbname=og_ckan_local --username=$PGUSER --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

      # import the database
      printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into og_ckan_local${NC}${SPACER}"
      pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=$PGDATABASE --username=$PGUSER ${APP_ROOT}/backup/ckan_db.pgdump

    fi
    # END
    # Destroy and re-import core database
    # END

    #
    # Destroy and re-import registry database
    #
    if [[ $installDB_Registry_CKAN == "true" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Drop the og_ckan_registry_local DB if it exists and then recreate it blank/clean${NC}${SPACER}"
      psql -eb --dbname=og_ckan_registry_local --username=$PGUSER --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_registry_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

      # import the database
      printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into og_ckan_registry_local${NC}${SPACER}"
      pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_registry_local --username=$PGUSER ${APP_ROOT}/backup/ckan_registry_db.pgdump

    fi
    # END
    # Destroy and re-import registry database
    # END

    #
    # Destroy and re-import registry datastore database
    #
    if [[ $installDB_Registry_DS_CKAN == "true" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Drop the og_ckan_registry_ds_local DB if it exists and then recreate it blank/clean${NC}${SPACER}"
      psql -eb --dbname=og_ckan_registry_ds_local --username=$PGUSER --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_registry_ds_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

      # import the database
      printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into og_ckan_registry_ds_local${NC}${SPACER}"
      pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_registry_ds_local --username=$PGUSER ${APP_ROOT}/backup/ckan_registry_ds_db.pgdump

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

      mkdir -p ${APP_ROOT}/ckan/default
      mkdir -p ${APP_ROOT}/ckan/registry
      mkdir -p ${APP_ROOT}/ckan/portal

      # nuke the entire folder
      printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing CKAN install${NC}${SPACER}"
      # destroy all files
      cd ${APP_ROOT}/ckan/default
      rm -rf ./*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all files in ckan/default: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all files in ckan/default: FAIL${NC}${EOL}"
      fi
      cd ${APP_ROOT}/ckan/registry
      rm -rf ./*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all files in ckan/registry: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all files in ckan/registry: FAIL${NC}${EOL}"
      fi
      cd ${APP_ROOT}/ckan/portal
      rm -rf ./*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all files in ckan/portal: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all files in ckan/portal: FAIL${NC}${EOL}"
      fi
      # destroy all hidden files
      cd ${APP_ROOT}/ckan/default
      rm -rf ./.??*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all hidden files in ckan/default: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all hidden files in ckan/default: FAIL${NC}${EOL}"
      fi
      cd ${APP_ROOT}/ckan/registry
      rm -rf ./.??*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all hidden files in ckan/registry: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all hidden files in ckan/registry: FAIL${NC}${EOL}"
      fi
      cd ${APP_ROOT}/ckan/portal
      rm -rf ./.??*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all hidden files in ckan/portal: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all hidden files in ckan/portal: FAIL${NC}${EOL}"
      fi

      # create virtual environment
      virtualenv --python=python2 ${APP_ROOT}/ckan/default
      cd ${APP_ROOT}/ckan/default

      # set ownership
      chown ckan:ckan -R ${APP_ROOT}/ckan
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set ckan ownership to ckan:ckan: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set ckan ownership to ckan:ckan: FAIL${NC}${EOL}"
      fi

      # activate python environment
      . ${APP_ROOT}/ckan/default/bin/activate
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Activate Python environment: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Activate Python environment: FAIL${NC}${EOL}"
      fi
      # install setup tools
      pip install setuptools==${SETUP_TOOLS_VERSION}
      # update pip
      pip install --upgrade pip==${PIP_VERSION}
      # set github as a trusted host
      ssh -T git@github.com
      # update certifi
      pip install --upgrade certifi
      # copy CA root pem chain
      cp /etc/ssl/mkcert/rootCA.pem /srv/app/ckan/default/lib/python${PY_VERSION}/site-packages/certifi/cacert.pem

      # install ckan core into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Core repository from git@github.com:open-data/ckan.git@canada-v2.8 and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/open-data/ckan.git@canada-v2.8#egg=ckan' -r 'https://raw.githubusercontent.com/open-data/ckan/canada-v2.8/requirements.txt'

      # copy local ckan config file
      cp ${APP_ROOT}/ckan.ini ${APP_ROOT}/ckan/default/ckan.ini
      printf "${SPACER}${Cyan}${INDENT}Copying local CKAN config file to into Python environment${NC}${SPACER}"
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ckan.ini to ckan/default/ckan.ini: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ckan.ini to ckan/default/ckan.ini: FAIL${NC}${EOL}"
      fi

      # copy core who config file
      cp ${APP_ROOT}/ckan/default/src/ckan/ckan/config/who.ini ${APP_ROOT}/ckan/default/who.ini
      printf "${SPACER}${Cyan}${INDENT}Copying Core CKAN who config file to into root Python environment${NC}${SPACER}"
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ckan/default/src/ckan/ckan/config/who.ini to ckan/default/who.ini: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ckan/default/src/ckan/ckan/config/who.ini to ckan/default/who.ini: FAIL${NC}${EOL}"
      fi

      # install ckanapi into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN API repository from git@github.com:ckan/ckanapi.git and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/ckan/ckanapi.git#egg=ckanapi' -r 'https://raw.githubusercontent.com/ckan/ckanapi/master/requirements.txt'

      # install ckan canada into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Canada repository from git@github.com:open-data/ckanext-canada.git and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/open-data/ckanext-canada.git#egg=ckanext-canada' -r 'https://raw.githubusercontent.com/open-data/ckanext-canada/master/requirements.txt'

      # install ckan cloud storage into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Cloud Storage repository from git@github.com:open-data/ckanext-cloudstorage.git and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/open-data/ckanext-cloudstorage.git#egg=ckanext-cloudstorage'

      # install ckan dcat into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN DCat repository from git@github.com:open-data/ckanext-dcat.git and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/open-data/ckanext-dcat.git#egg=ckanext-dcat' -r 'https://raw.githubusercontent.com/open-data/ckanext-dcat/master/requirements.txt'

      # install ckan extended activity into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Extended Activity repository from git@github.com:open-data/ckanext-extendedactivity.git and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/open-data/ckanext-extendedactivity.git#egg=ckanext-extendedactivity'

      # install ckan extractor into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Extractor repository from git@github.com:open-data/ckanext-extractor.git and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/open-data/ckanext-extractor.git#egg=ckanext-extractor' -r 'https://raw.githubusercontent.com/open-data/ckanext-extractor/master/requirements.txt'

      # install ckan fluent into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Fluent repository from git@github.com:ckan/ckanext-fluent.git and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/ckan/ckanext-fluent.git#egg=ckanext-fluent' -r 'https://raw.githubusercontent.com/ckan/ckanext-fluent/master/requirements.txt'

      # install ckan recombinant into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Recombinant repository from git@github.com:open-data/ckanext-recombinant.git and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/open-data/ckanext-recombinant.git#egg=ckanext-recombinant' -r 'https://raw.githubusercontent.com/open-data/ckanext-recombinant/master/requirements.txt'

      # install ckan scheming into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Scheming repository from git@github.com:ckan/ckanext-scheming.git and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/ckan/ckanext-scheming.git#egg=ckanext-scheming'

      # install ckan security into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Security repository from git@github.com:open-data/ckanext-security.git and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/open-data/ckanext-security.git#egg=ckanext-security'

      # install ckan validation into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Validation repository from git@github.com:open-data/ckanext-validation.git and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/open-data/ckanext-validation.git#egg=ckanext-validation' -r 'https://raw.githubusercontent.com/open-data/ckanext-validation/master/requirements.txt'

      # install ckan xloader into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Xloader repository from git@github.com:open-data/ckanext-xloader.git and installing into Python environment${NC}${SPACER}"
      pip install --force-reinstall -e 'git+ssh://git@github.com/open-data/ckanext-xloader.git#egg=ckanext-xloader' -r 'https://raw.githubusercontent.com/open-data/ckanext-xloader/master/requirements.txt'

      # decativate python environment
      deactivate
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
      fi

      # set ownership
      chown ckan:ckan -R ${APP_ROOT}/ckan
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set ckan ownership to ckan:ckan: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set ckan ownership to ckan:ckan: FAIL${NC}${EOL}"
      fi

      # copy default environment into portal and registry environments
      printf "${SPACER}${Cyan}${INDENT}Copying default Python environment into ckan/portal and ckan/registry${NC}${SPACER}"
      cp -R ${APP_ROOT}/ckan/default/* ${APP_ROOT}/ckan/portal/
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ckan/default to ckan/portal: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ckan/default to ckan/portal: FAIL${NC}${EOL}"
      fi
      cp -R ${APP_ROOT}/ckan/default/* ${APP_ROOT}/ckan/registry/
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ckan/default to ckan/registry: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ckan/default to ckan/registry: FAIL${NC}${EOL}"
      fi

      # copy portal ckan config file
      cp ${APP_ROOT}/portal.ini ${APP_ROOT}/ckan/portal/portal.ini
      printf "${SPACER}${Cyan}${INDENT}Copying local portal CKAN config file to into portal Python environment${NC}${SPACER}"
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy portal.ini to ckan/portal/portal.ini: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy portal.ini to ckan/portal/portal.ini: FAIL${NC}${EOL}"
      fi

      # copy registry ckan config file
      cp ${APP_ROOT}/registry.ini ${APP_ROOT}/ckan/registry/registry.ini
      printf "${SPACER}${Cyan}${INDENT}Copying local registry CKAN config file to into registry Python environment${NC}${SPACER}"
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy registry.ini to ckan/registry/registry.ini: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy registry.ini to ckan/registry/registry.ini: FAIL${NC}${EOL}"
      fi

      # create storage paths
      printf "${SPACER}${Cyan}${INDENT}Create storage paths${NC}${SPACER}"
      mkdir -p ${APP_ROOT}/ckan/default/storage
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create ckan/default/storage: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Create ckan/default/storage: FAIL (directory may already exist)${NC}${EOL}"
      fi
      mkdir -p ${APP_ROOT}/ckan/portal/storage
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create ckan/portal/storage: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Create ckan/portal/storage: FAIL (directory may already exist)${NC}${EOL}"
      fi
      mkdir -p ${APP_ROOT}/ckan/registry/storage
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create ckan/registry/storage: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Create ckan/registry/storage: FAIL (directory may already exist)${NC}${EOL}"
      fi

    fi
    # END
    # Destroy and pull and install fast-forwarded repositories
    # END

    #
    # Set file permissions
    #
    if [[ $installFilePermissions_CKAN == "true" ]]; then

      # set file ownership for ckan-ext files
      chown ckan:ckan -R ${APP_ROOT}/ckan
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set ckan ownership to ckan:ckan: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set ckan ownership to ckan:ckan: FAIL${NC}${EOL}"
      fi

    fi
    # END
    # Set file permissions
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
# Install Databases
#
function install_databases {

  psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
    CREATE USER homestead;
    ALTER USER homestead PASSWORD 'secret';
    CREATE USER homestead_reader;
    ALTER USER homestead_reader PASSWORD 'secret';
    CREATE DATABASE og_drupal_local;
    CREATE DATABASE og_ckan_local;
    CREATE DATABASE og_ckan_registry_local;
    CREATE DATABASE og_ckan_registry_ds_local;
    GRANT ALL PRIVILEGES ON DATABASE og_drupal_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_registry_ds_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_drupal_local TO homestead_reader;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_local TO homestead_reader;
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
    "CKAN"
    "Databases (fixes missing databases, privileges, and users)"
    "All" 
    "Exit"
  )

fi

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

  # "Drupal or CKAN"
  (0) 
    if [[ ${CONTAINER_ROLE} == "drupal" ]]; then
      exitScript='false'
      installDrupal='true'
    elif [[ ${CONTAINER_ROLE} == "ckan" ]]; then
      exitScript='false'
      installCKAN='true'
    fi
    ;;

  (2)
    exitScript='false'
    installDatabases='true'
    ;;

  # "All"
  (3) 
    exitScript='false'
    installDrupal='true'
    installCKAN='true'
    installDatabases='true'
    ;;

  # "Exit"
  (4)
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

else

  printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi
# END
# Run Script
# END