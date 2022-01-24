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

      printf "${SPACER}${Cyan}${INDENT}Drop the DB if it exists and then recreate it blank/clean${NC}${SPACER}"
      psql -eb --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_drupal_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

      # import the database
      echo "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup${SPACER}"
      pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=$PGDATABASE --username=$PGUSER /var/www/html/backup/drupal_db.pgdump

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

      mkdir -p /var/www/html/drupal
      cd /var/www/html/drupal

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
      cd /var/www/html/drupal/html/profiles/og
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
      cd /var/www/html/drupal/html/themes/custom/gcweb
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
      mkdir -p /var/www/html/drupal/html/sites/default
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create sites/default: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Create sites/default: FAIL (directory may already exist)${NC}${EOL}"
      fi
      # remove default files directory
      rm -rf /var/www/html/drupal/html/sites/default/files
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Removed sites/default/files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Removed sites/default/files: FAIL (directory may not exist)${NC}${EOL}"
      fi
      cd /var/www/html/drupal/html/sites/default
      tar zxvf /var/www/html/backup/drupal_files.tgz

    fi
    # END
    # Install Local Files
    # END

    #
    # Set file and directory ownership and permissions
    #
    if [[ $installFilePermissions_Drupal == "true" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Download Drupal default settings file${NC}${SPACER}"
      cd /var/www/html/drupal/html/sites
      # remove old settings file
      rm -rf /var/www/html/drupal/html/sites/default.settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Removed sites/default.settings.php: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Removed sites/default.settings.php: FAIL (file may not exist)${NC}${EOL}"
      fi
      wget https://raw.githubusercontent.com/drupal/drupal/8.8.x/sites/default/default.settings.php
      mkdir -p /var/www/html/drupal/html/sites/default
      cd /var/www/html/drupal/html/sites/default
      # remove old settings file
      rm -rf /var/www/html/drupal/html/sites/default/default.settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Removed sites/default/default.settings.php: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Removed sites/default/default.settings.php: FAIL (file may not exist)${NC}${EOL}"
      fi
      wget https://raw.githubusercontent.com/drupal/drupal/8.8.x/sites/default/default.settings.php

      printf "${SPACER}${Cyan}${INDENT}Copy Drupal settings file${NC}${SPACER}"
      # copy docker config settings.php to drupal directory
      cp /var/www/html/drupal-local-settings.php /var/www/html/drupal/html/sites/settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied drupal-local-settings.php to sites/settings.php: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copied drupal-local-settings.php to sites/settings.php: FAIL${NC}${EOL}"
      fi
      # copy docker config settings.php to drupal directory
      cp /var/www/html/drupal-local-settings.php /var/www/html/drupal/html/sites/default/settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied drupal-local-settings.php to sites/default/settings.php: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copied drupal-local-settings.php to sites/default/settings.php: FAIL${NC}${EOL}"
      fi

      printf "${SPACER}${Cyan}${INDENT}Set Drupal settings file permissions${NC}${SPACER}"
      # set file permissions for settings file
      chmod 644 /var/www/html/drupal/html/sites/settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/settings.php perms to 644: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/settings.php perms to 644: FAIL${NC}${EOL}"
      fi
      # set file permissions for default settings file
      chmod 644 /var/www/html/drupal/html/sites/default.settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default.settings.php perms to 644: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/default.settings.php to 644: FAIL${NC}${EOL}"
      fi
      # set file permissions for settings file
      chmod 644 /var/www/html/drupal/html/sites/default/settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/settings.php perms to 644: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/default/settings.php perms to 644: FAIL${NC}${EOL}"
      fi
      # set file permissions for default settings file
      chmod 644 /var/www/html/drupal/html/sites/default/default.settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/default.settings.php perms to 644: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/default/default.settings.php perms to 644: FAIL${NC}${EOL}"
      fi

      printf "${SPACER}${Cyan}${INDENT}Create config sync directory${NC}${SPACER}"
      # create drupal config sync directory
      mkdir -p /var/www/html/drupal/html/sites/default/sync
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create sites/default/sync: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Create sites/default/sync: FAIL (directory may already exist)${NC}${EOL}"
      fi

      printf "${SPACER}${Cyan}${INDENT}Create private files directory${NC}${SPACER}"
      #create private files directory
      mkdir -p /var/www/html/drupal/html/sites/default/private-files
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create sites/default/private-files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Create sites/default/private-files: FAIL (directory may already exist)${NC}${EOL}"
      fi
      # add htaccess file
      echo "Deny from all" > /var/www/html/drupal/html/sites/default/private-files/.htaccess
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Added Deny from all to private files directory: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Added Deny from all to private files directory: FAIL${NC}${EOL}"
      fi
      # set file permissions of new htaccess file
      chmod 644 /var/www/html/drupal/html/sites/default/private-files/.htaccess
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set private directory htaccess perms to 644: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set private directory htaccess perms to 644: FAIL${NC}${EOL}"
      fi

      printf "${SPACER}${Cyan}${INDENT}Set public files permissions${NC}${SPACER}"
      # set file permissions of public files directory
      chmod 755 /var/www/html/drupal/html/sites/default/files
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/files perms to 755: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/default/files perms to 755: FAIL${NC}${EOL}"
      fi

      # set file permissions of public files inner directories
      find /var/www/html/drupal/html/sites/default/files -type d -exec chmod 755 {} \;
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/files inner directory perms to 755: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/default/files inner directory perms to 755: FAIL${NC}${EOL}"
      fi

      # set file permissions of public files inner files
      find /var/www/html/drupal/html/sites/default/files -type f -exec chmod 644 {} \;
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/files inner files perms to 644: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set sites/default/files inner files perms to 644: FAIL${NC}${EOL}"
      fi

      printf "${SPACER}${Cyan}${INDENT}Set Drupal file ownership${NC}${SPACER}"
      # set file system ownership for the drupal directory
      chown www-data:www-data -R /var/www/html/drupal
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
        cd /var/www/html/drupal
        drush uinf admin.local || drush user:create admin.local --mail=temp@tbs-sct.gc.ca --password=12345678
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
    "Database" 
    "Repositories" 
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

    # "Database"
    (1) 
      exitScript='false'
      installDB_CKAN='true'
      ;;

    # "Repositories"
    (2) 
      exitScript='false'
      installRepos_CKAN='true'
      ;;

    # "Set File Permissions"
    (3)
      exitScript='false'
      installFilePermissions_CKAN='true'
      ;;

    # "All"
    (4) 
      exitScript='false'
      installSSH_CKAN='true'
      installDB_CKAN='true'
      installRepos_CKAN='true'
      installFilePermissions_CKAN='true'
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
    # Confirm CKAN database destruction
    #
    if [[ $installDB_CKAN == "true" ]]; then

      read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing CKAN database and import a fresh copy? [y/N]:\033[0;0m    ' response

      if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installDB_CKAN='true'

      else

        installDB_CKAN='false'

      fi

    fi
    # END
    # Confirm CKAN database destruction
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
    # Destroy and re-import database
    #
    if [[ $installDB_CKAN == "true" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Drop the DB if it exists and then recreate it blank/clean${NC}${SPACER}"
      psql -eb --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

      # import the database
      echo "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup${SPACER}"
      #pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=$PGDATABASE --username=$PGUSER /var/www/html/backup/ckan_db.pgdump

    fi
    # END
    # Destroy and re-import database
    # END

    #
    # Destroy and pull fast-forwarded repositories
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

      #TODO: do all of this inside of the python environment...

      mkdir -p /var/www/html/ckan
      cd /var/www/html/ckan

      # nuke the entire folder
      printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing CKAN install${NC}${SPACER}"
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

      # pull the core ckan repo
      mkdir -p /var/www/html/ckan/core
      cd /var/www/html/ckan/core
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Core repository from git@github.com:open-data/ckan.git${NC}${SPACER}"
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
      git remote add origin git@github.com:open-data/ckan.git
      git pull git@github.com:open-data/ckan.git

      # pull the extension ckan repo
      mkdir -p /var/www/html/ckan/ca-ext
      cd /var/www/html/ckan/ca-ext
      printf "${SPACER}${Cyan}${INDENT}Pulling CKAN Extension repository from git@github.com:open-data/ckanext-canada.git${NC}${SPACER}"
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
      git remote add origin git@github.com:open-data/ckanext-canada.git
      git pull git@github.com:open-data/ckanext-canada.git

    fi
    # END
    # Destroy and pull fast-forwarded repositories
    # END

    #
    # Set file permissions
    #
    if [[ $installFilePermissions_CKAN == "true" ]]; then

      # set file ownership for ckan-ext files
      chown ckan:ckan -R /var/www/html/ckan
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
    CREATE DATABASE og_drupal_local;
    CREATE DATABASE og_ckan_local;
    GRANT ALL PRIVILEGES ON DATABASE og_drupal_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_ckan_local TO homestead;
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

# Options for the user to select from
options=(
  "Drupal" 
  "CKAN"
  "Databases (fixes missing databases, privileges, and users)"
  "All" 
  "Exit"
)

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

  # "Drupal"
  (0) 
    exitScript='false'
    installDrupal='true'
    ;;

  # "CKAN"
  (1) 
    exitScript='false'
    installCKAN='true'
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