#!/bin/bash

read -r -p "Are you sure you want delete the existing Drupal site and install a fresh copy? [y/N] " response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  mkdir -p drupal
  cd drupal

  # nuke the entire folder
  echo "--- Pre-nuke the existing Drupal install"
  rm ./* -rf

  echo "--- Drop the DB if it exists and then recreate it blank/clean"
  #--username=root
  psql -eb --host=postgres --username=postgres --command='dropdb og_d8_local'
  psql -eb --host=postgres --username=postgres --command='createdb og_d8_local'
  psql -eb --host=postgres --username=postgres -e --command="grant all on og_d8_local.* to 'homestead'@'%' identified by 'secret';"

  # import the database
  echo "--- Import the database from the pg_dump backup"
  echo "------ TODO: import database..."
  #pg_restore -v --host=postgres --username=homestead --file='../backup/db.pgdump'

  # unzip the site
  echo "--- Pulling OG repository from https://github.com/open-data/opengov.git"
  git init
  git config --global init.defaultBranch master
  git config pull.ff only
  git remote add origin https://github.com/open-data/opengov.git
  git pull https://github.com/open-data/opengov.git

  echo "--- Copy Drupal settings file"
  cp ../drupal-local-settings.php ./html/sites/settings.php

  echo "--- Set local user admin"
  drush user-create admin temp@tbs-sct.gc.ca --role=administrator --password=12345678

  echo "--- Run me: https://open.local"
fi