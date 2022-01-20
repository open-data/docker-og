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

# flags
installSSH='false'
installDB='false'
installRepos='false'
installFiles='false'
installFilePermissions='false'
installLocalUser='false'
exitScript='false'

# END
# Variables
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
    installSSH='true'
    ;;

  # "Database"
  (1) 
    installDB='true'
    ;;

  # "Repositories"
  (2) 
    installRepos='true'
    ;;

  # "Local Files"
  (3)
    installFiles='true'
    ;;

  # "Set File Permissions (also creates missing directories)"
  (4)
    installFilePermissions='true'
    ;;

  # "Create Local User"
  (5)
    installLocalUser='true'
    ;;

  # "All"
  (6) 
    installSSH='true'
    installDB='true'
    installRepos='true'
    installFiles='true'
    installFilePermissions='true'
    installLocalUser='true'
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
  if [[ $installDB == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing Drupal database and import a fresh copy? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

      installDB='true'

    else

      installDB='false'

    fi

  fi
  # END
  # Confirm Drupal database destruction
  # END

  #
  # Confirm Drupal repo destruction
  #
  if [[ $installRepos == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing Drupal directory and pull fast-forwarded repositories? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

      installRepos='true'

    else

      installRepos='false'

    fi

  fi
  # END
  # Confirm Drupal repo destruction
  # END

  #
  # Confirm Drupal local file destruction
  #
  if [[ $installFiles == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing Drupal public files and import from the tar ball? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

      installFiles='true'

    else

      installFiles='false'

    fi

  fi
  # END
  # Confirm Drupal local file destruction
  # END

  #
  # Install and configure SSH and Agent
  #
  if [[ $installSSH == "true" ]]; then

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

  else

    printf "${SPACER}${Yellow}${INDENT}...skipping SSH install and config...${NC}${SPACER}"

  fi
  # END
  # Install and configure SSH and Agent
  # END

  #
  # Destroy and re-import the Drupal database
  #
  if [[ $installDB == "true" ]]; then

    printf "${SPACER}${Cyan}${INDENT}Drop the DB if it exists and then recreate it blank/clean${NC}${SPACER}"
    psql -eb --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_d8_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

    # import the database
    echo "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup${SPACER}"
    pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=$PGDATABASE --username=$PGUSER /var/www/html/backup/db.pgdump

  else

    printf "${SPACER}${Yellow}${INDENT}...skipping drop and recover database$...{NC}${SPACER}"

  fi
  # END
  # Destroy and re-import the Drupal database
  # END

  #
  # Pull Drupal Core repo, Drupal profile repo, and Drupal theme repo
  #
  if [[ $installRepos == "true" ]]; then

    if [[ $installSSH != "true" ]]; then

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

  else

    printf "${SPACER}${Yellow}${INDENT}...skipping destroy directories and pull repos...${NC}${SPACER}"

  fi
  # END
  # Pull Drupal Core repo, Drupal profile repo, and Drupal theme repo
  # END

  #
  # Install Local Files
  #
  if [[ $installFiles == "true" ]]; then

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
    tar zxvf /var/www/html/backup/files.tgz

  else

    printf "${SPACER}${Yellow}${INDENT}...skipping destroy Drupal public files and tar ball extraction...${NC}${SPACER}"

  fi
  # END
  # Install Local Files
  # END

  #
  # Set file and directory ownership and permissions
  #
  if [[ $installFilePermissions == "true" ]]; then

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

  else

    printf "${SPACER}${Yellow}${INDENT}...skipping file ownership and permissions...${NC}${SPACER}"

  fi
  # END
  # Set file and directory ownership and permissions
  # END

  #
  # Create Drupal admin user
  #
  if [[ $installLocalUser == "true" ]]; then

    if [[ -x "$(command -v drush)" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Set local user admin${NC}${SPACER}"
      cd /var/www/html/drupal
      drush uinf admin.local || drush user:create admin.local --mail=temp@tbs-sct.gc.ca --password=12345678
      drush urol administrator admin.local

    else

      printf "${SPACER}${Yellow}${INDENT}Drush command not found...skipping local Drupal user creation...${NC}${SPACER}"

    fi

  else

    printf "${SPACER}${Yellow}${INDENT}...skipping local Drupal user creation...${NC}${SPACER}"

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