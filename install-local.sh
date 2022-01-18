#!/bin/bash

read -r -p $'\n\n\033[0;31m    Are you sure you want delete the existing Drupal site and install a fresh copy? [y/N]\033[0;0m' response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

  # text
  Cyan='\033[0;36m'
  Yellow='\033[1;33m'
  Red='\033[0;31m'
  Green='\033[0;32m'
  NC='\033[0;0m'
  SPACER='\n\n';

  # flags
  skipSSH=''
  skipDB=''
  skipRepos=''

  while getopts :-: option; do

    case "-$option$OPTARG" in

      (--skip-ssh) skipSSH='true' ;;

      (--skip-db) skipDB='true' ;;

      (--skip-repos) skipRepos='true' ;;

    esac

  done

  if [[ $skipSSH != "true" ]]; then

    # install SSH
    printf "${SPACER}${Cyan}    Install SSH for GIT use${NC}${SPACER}"
    which ssh || apt install ssh -y

    # set strict host checking to false
    printf "${SPACER}${Cyan}    Set strict SSH host checking to false${NC}${SPACER}"
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

  else

    printf "${SPACER}${Yellow}    Skip SSH set...skipping SSH install and config${NC}${SPACER}"

  fi

  if [[ $skipDB != "true" ]]; then

    printf "${SPACER}${Cyan}    Drop the DB if it exists and then recreate it blank/clean${NC}${SPACER}"
    psql -eb --command='DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_d8_local TO homestead; GRANT ALL ON SCHEMA public TO homestead;'

    # import the database
    echo "${SPACER}${Cyan}    Import the database from the pg_dump backup${SPACER}"
    pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=$PGDATABASE --username=$PGUSER /var/www/html/backup/db.pgdump

  else

    printf "${SPACER}${Yellow}    Skip DB set...skipping drop and recover database${NC}${SPACER}"

  fi

  if [[ $skipRepos != "true" ]]; then

    mkdir -p /var/www/html/drupal
    cd /var/www/html/drupal

    # nuke the entire folder
    printf "${SPACER}${Cyan}    Pre-nuke the existing Drupal install${NC}${SPACER}"
    rm -rf ./*
    rm -rf ./.??*

    # pull the core site
    printf "${SPACER}${Cyan}    Pulling OG repository from git@github.com:open-data/opengov.git${NC}${SPACER}"
    git config --global init.defaultBranch master
    rm -rf .git
    git init
    git config pull.ff only
    git remote add origin git@github.com:open-data/opengov.git
    git pull git@github.com:open-data/opengov.git

    # pull the profile
    printf "${SPACER}${Cyan}    Pulling Profile repository from git@github.com:open-data/og.git${NC}${SPACER}"
    cd /var/www/html/drupal/html/profiles/og
    rm -rf .git
    git init
    git config pull.ff only
    git remote add origin git@github.com:open-data/og.git
    git pull git@github.com:open-data/og.git

    # pull the theme
    printf "${SPACER}${Cyan}    Pulling Theme repository from git@github.com:open-data/gcweb_bootstrap.git${NC}${SPACER}"
    cd /var/www/html/drupal/html/themes/custom/gcweb
    rm -rf .git
    git init
    git config pull.ff only
    git remote add origin git@github.com:open-data/gcweb_bootstrap.git
    git pull git@github.com:open-data/gcweb_bootstrap.git

    printf "${SPACER}${Cyan}    Copy Drupal settings file${NC}${SPACER}"
    mkdir -p /var/www/html/drupal/html/sites/default
    cp /var/www/html/drupal-local-settings.php /var/www/html/drupal/html/sites/settings.php
    cp /var/www/html/drupal-local-settings.php /var/www/html/drupal/html/sites/default/settings.php

    printf "${SPACER}${Cyan}    Set local user admin${NC}${SPACER}"
    drush user:create admin temp@tbs-sct.gc.ca --role=administrator --password=12345678

  else

    printf "${SPACER}${Yellow}    Skip Repos set...skipping destroy directories and pull repos${NC}${SPACER}"

  fi

  printf "${SPACER}${Green}    Run me: https://open.local${NC}${SPACER}"

fi