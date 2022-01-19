#!/bin/bash

# text
Cyan='\033[0;36m'
Yellow='\033[1;33m'
Red='\033[0;31m'
Green='\033[0;32m'
NC='\033[0;0m'
SPACER='\n\n';
INDENT='    ';

# flags
installSSH='false'
installDB='false'
installRepos='false'
exitScript='false'

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

printf "${SPACER}${Cyan}${INDENT}Select what to install:${NC}${SPACER}"

#TODO: split up Repositories option to "Local Files", "Set File Permissions", and "Create Local User"
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

  # "All"
  (3) 
    installSSH='true'
    installDB='true'
    installRepos='true'
    ;;

  # "Exit"
  (4)
    exitScript='true'
    ;;

esac

if [[ $exitScript != "true" ]]; then

  if [[ $installDB == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing Drupal database and import a fresh copy? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

      installDB='true'

    else

      installDB='false'

    fi

  fi

  if [[ $installRepos == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing Drupal directory and pull fast-forwarded repositories? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

      installRepos='true'

    else

      installRepos='false'

    fi

  fi

  if [[ $installSSH == "true" ]]; then

    # install SSH
    printf "${SPACER}${Cyan}${INDENT}Install SSH for GIT use${NC}${SPACER}"
    which ssh || apt install ssh -y

    # set strict host checking to false
    printf "${SPACER}${Cyan}${INDENT}Set strict SSH host checking to false${NC}${SPACER}"
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

  else

    printf "${SPACER}${Yellow}${INDENT}Skip SSH set...skipping SSH install and config${NC}${SPACER}"

  fi

  if [[ $installDB == "true" ]]; then

    printf "${SPACER}${Cyan}${INDENT}Drop the DB if it exists and then recreate it blank/clean${NC}${SPACER}"
    psql -eb --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_d8_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

    # import the database
    echo "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup${SPACER}"
    pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=$PGDATABASE --username=$PGUSER /var/www/html/backup/db.pgdump

  else

    printf "${SPACER}${Yellow}${INDENT}Skip DB set...skipping drop and recover database${NC}${SPACER}"

  fi

  if [[ $installRepos == "true" ]]; then

    if [[ $installSSH != "true" ]]; then

      # check for SSH agent
      printf "${SPACER}${Cyan}${INDENT}Check if SSH Agent is installed and configured${NC}${SPACER}"
      which ssh || apt install ssh -y

      # set strict host checking to false
      printf "${SPACER}${Cyan}${INDENT}Set strict SSH host checking to false${NC}${SPACER}"
      echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

    fi

    mkdir -p /var/www/html/drupal
    cd /var/www/html/drupal

    # nuke the entire folder
    printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing Drupal install${NC}${SPACER}"
    rm -rf ./*
    rm -rf ./.??*

    # pull the core site
    printf "${SPACER}${Cyan}${INDENT}Pulling OG repository from git@github.com:open-data/opengov.git${NC}${SPACER}"
    git config --global init.defaultBranch master
    rm -rf .git
    git init
    git config pull.ff only
    git remote add origin git@github.com:open-data/opengov.git
    git pull git@github.com:open-data/opengov.git

    # pull the profile
    printf "${SPACER}${Cyan}${INDENT}Pulling Profile repository from git@github.com:open-data/og.git${NC}${SPACER}"
    cd /var/www/html/drupal/html/profiles/og
    rm -rf .git
    git init
    git config pull.ff only
    git remote add origin git@github.com:open-data/og.git
    git pull git@github.com:open-data/og.git

    # pull the theme
    printf "${SPACER}${Cyan}${INDENT}Pulling Theme repository from git@github.com:open-data/gcweb_bootstrap.git${NC}${SPACER}"
    cd /var/www/html/drupal/html/themes/custom/gcweb
    rm -rf .git
    git init
    git config pull.ff only
    git remote add origin git@github.com:open-data/gcweb_bootstrap.git
    git pull git@github.com:open-data/gcweb_bootstrap.git

    printf "${SPACER}${Cyan}${INDENT}Download Drupal default settings file${NC}${SPACER}"
    cd /var/www/html/drupal/html/sites
    wget https://raw.githubusercontent.com/drupal/drupal/8.8.x/sites/default/default.settings.php
    mkdir -p /var/www/html/drupal/html/sites/default
    cd /var/www/html/drupal/html/sites/default
    wget https://raw.githubusercontent.com/drupal/drupal/8.8.x/sites/default/default.settings.php

    printf "${SPACER}${Cyan}${INDENT}Copy Drupal settings file${NC}${SPACER}"
    cp /var/www/html/drupal-local-settings.php /var/www/html/drupal/html/sites/settings.php
    cp /var/www/html/drupal-local-settings.php /var/www/html/drupal/html/sites/default/settings.php

    printf "${SPACER}${Cyan}${INDENT}Set Drupal settings file permissions${NC}${SPACER}"
    chmod 644 /var/www/html/drupal/html/sites/settings.php
    chmod 644 /var/www/html/drupal/html/sites/default.settings.php
    chmod 644 /var/www/html/drupal/html/sites/default/settings.php
    chmod 644 /var/www/html/drupal/html/sites/default/default.settings.php

    printf "${SPACER}${Cyan}${INDENT}Extract public files from backup${NC}${SPACER}"
    cd /var/www/html/drupal/html/sites/default
    tar zxvf /var/www/html/backup/files.tgz

    printf "${SPACER}${Cyan}${INDENT}Create config sync directory${NC}${SPACER}"
    mkdir -p /var/www/html/drupal/html/sites/default/sync

    printf "${SPACER}${Cyan}${INDENT}Create private files directory${NC}${SPACER}"
    mkdir -p /var/www/html/drupal/html/sites/default/private-files
    echo "Deny from all" > /var/www/html/drupal/html/sites/default/private-files/.htaccess
    chmod 644 /var/www/html/drupal/html/sites/default/private-files/.htaccess

    printf "${SPACER}${Cyan}${INDENT}Set public files permissions${NC}${SPACER}"
    chmod 755 /var/www/html/drupal/html/sites/default/files
    find /var/www/html/drupal/html/sites/default/files -type d -exec chmod 755 {} \;
    find /var/www/html/drupal/html/sites/default/files -type f -exec chmod 644 {} \;

    printf "${SPACER}${Cyan}${INDENT}Set Drupal file ownership${NC}${SPACER}"
    chown www-data:www-data -R /var/www/html/drupal

    printf "${SPACER}${Cyan}${INDENT}Set local user admin${NC}${SPACER}"
    cd /var/www/html/drupal
    drush user:create admin.local --mail=temp@tbs-sct.gc.ca --password=12345678
    drush urol administrator admin.local

    printf "${SPACER}${Cyan}${INDENT}Perform database updates${NC}${SPACER}"
    drush updb --yes

    printf "${SPACER}${Cyan}${INDENT}Clear Drupal caches${NC}${SPACER}"
    drush cr

  else

    printf "${SPACER}${Yellow}${INDENT}Skip Repos set...skipping destroy directories and pull repos${NC}${SPACER}"

  fi

  printf "${SPACER}${Green}${INDENT}Run me: https://open.local${NC}${SPACER}"

else

  printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi