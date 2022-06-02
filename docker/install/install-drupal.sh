#!/bin/bash

printf "${SPACER}${Cyan}${INDENT}Select what to install for ${BOLD}Drupal:${HAIR}${NC}${SPACER}"

  # Options for the user to select from
  options=(
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

    # "Database"
    (0) 
      exitScript='false'
      installDB_Drupal='true'
      ;;

    # "Repositories"
    (1) 
      exitScript='false'
      installRepos_Drupal='true'
      ;;

    # "Local Files"
    (2)
      exitScript='false'
      installFiles_Drupal='true'
      ;;

    # "Set File Permissions (also creates missing directories)"
    (3)
      exitScript='false'
      installFilePermissions_Drupal='true'
      ;;

    # "Create Local User"
    (4)
      exitScript='false'
      installLocalUser_Drupal='true'
      ;;

    # "All"
    (5) 
      exitScript='false'
      installDB_Drupal='true'
      installRepos_Drupal='true'
      installFiles_Drupal='true'
      installFilePermissions_Drupal='true'
      installLocalUser_Drupal='true'
      ;;

    # "Exit"
    (6)
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
    # Destroy and re-import the Drupal database
    #
    if [[ $installDB_Drupal == "true" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_drupal_local__${PROJECT_ID} DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
      psql -eb --dbname=og_drupal_local__${PROJECT_ID} --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_drupal_local__${PROJECT_ID} TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

      # import the database
      printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_drupal_local__${PROJECT_ID}${HAIR}${NC}${SPACER}"
      pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=$PGDATABASE --username=$PGUSER ${APP_ROOT}/backup/drupal_db.pgdump

    fi
    # END
    # Destroy and re-import the Drupal database
    # END

    #
    # Pull Drupal Core repo, Drupal profile repo, and Drupal theme repo
    #
    if [[ $installRepos_Drupal == "true" ]]; then

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
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}OG repository${HAIR}${Cyan} from https://github.com/open-data/opengov.git${NC}${SPACER}"
      git config --global init.defaultBranch master
      # destroy the local git repo config
      rm -rf .git
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove .git: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove .git: FAIL (local repo may not exist)${NC}${EOL}"
      fi
      rm -rf ./*
      rm -rf ./.??*
      git clone https://github.com/open-data/opengov.git .

      # pull the profile
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}Profile repository${HAIR}${Cyan} from https://github.com/open-data/og.git${NC}${SPACER}"
      # destroy the local git repo config
      cd ${APP_ROOT}/drupal/html/profiles/og
      rm -rf .git
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove profiles/og/.git: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove profiles/og/.git: FAIL (local repo may not exist)${NC}${EOL}"
      fi
      rm -rf ./*
      rm -rf ./.??*
      git clone https://github.com/open-data/og.git .

      # pull the theme
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}Theme repository${HAIR}${Cyan} from https://github.com/open-data/gcweb_bootstrap.git${NC}${SPACER}"
      cd ${APP_ROOT}/drupal/html/themes/custom/gcweb
      # destroy the local git repo config
      rm -rf .git
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove themes/custom/gcweb/.git: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove themes/custom/gcweb/.git: FAIL (local repo may not exist)${NC}${EOL}"
      fi
      rm -rf ./*
      rm -rf ./.??*
      git clone https://github.com/open-data/gcweb_bootstrap.git .

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
      cp ${APP_ROOT}/_config/drupal/settings.php ${APP_ROOT}/drupal/html/sites/settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied settings.php to sites/settings.php: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copied settings.php to sites/settings.php: FAIL${NC}${EOL}"
      fi
      # copy docker config settings.php to drupal directory
      cp ${APP_ROOT}/_config/drupal/settings.php ${APP_ROOT}/drupal/html/sites/default/settings.php
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied settings.php to sites/default/settings.php: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copied settings.php to sites/default/settings.php: FAIL${NC}${EOL}"
      fi

      printf "${SPACER}${Cyan}${INDENT}Copy Drupal services file${NC}${SPACER}"
      # copy docker config development.services.yml to drupal directory
      cp ${APP_ROOT}/_config/drupal/services.yml ${APP_ROOT}/drupal/html/sites/development.services.yml
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied services.yml to sites/development.services.yml: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copied services.yml to sites/development.services.yml: FAIL${NC}${EOL}"
      fi
      # copy docker config development.services.yml to drupal directory
      cp ${APP_ROOT}/_config/drupal/services.yml ${APP_ROOT}/drupal/html/sites/default/development.services.yml
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied services.yml to sites/default/development.services.yml: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copied services.yml to sites/default/development.services.yml: FAIL${NC}${EOL}"
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

    printf "${SPACER}${Green}${INDENT}Run me: ${BOLD}https://open-${PROJECT_ID}.local${HAIR}${NC}${SPACER}"

  else

    printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

  fi
  # END
  # Run Script
  # END