#!/bin/bash

#
# Download required search files and install them into the App
#
if [[ $installSearches_Django == "true" ]]; then

  # clear yaml config directory
  printf "${SPACER}"
  if [[ -d "${APP_ROOT}/django/ckan_config_files" ]]; then

    printf "${Cyan}${INDENT}Destroying old ckan_config_files directory...${NC}${EOL}"
    rm -rf ${APP_ROOT}/django/ckan_config_files

  fi
  printf "${Cyan}${INDENT}Creating ckan_config_files directory...${NC}${EOL}"
  mkdir -p ${APP_ROOT}/django/ckan_config_files

  # download yaml config files
  printf "${SPACER}${Cyan}${INDENT}Download CKAN config files${NC}${EOL}"
  mkdir -p ${APP_ROOT}/django/ckan_config_files
  cd ${APP_ROOT}/django/ckan_config_files
  wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/schemas/presets.yaml
  wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/briefingt.yaml
  wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/contracts.yaml
  wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/grants.yaml
  wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/nap.yaml
  wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/qpnotes.yaml
  wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/service.yaml
  wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/choices/minister.json
  wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/schemas/prop.yaml

  # clone oc_searches repo from https://github.com/thriuin/oc_searches
  printf "${SPACER}${Cyan}${INDENT}Pulling search files from https://github.com/thriuin/oc_searches${NC}${EOL}"
  if [[ ! -d "${APP_ROOT}/django/_searches" ]]; then
    mkdir -p ${APP_ROOT}/django/_searches
  fi
  if [[ ! -d "${APP_ROOT}/django/_searches/.git" ]]; then
    git clone https://github.com/thriuin/oc_searches.git ${APP_ROOT}/django/_searches
  else
    cd ${APP_ROOT}/django/_searches
    git fetch
    git pull
  fi
  cd ${APP_ROOT}
  searches_import_dir="${APP_ROOT}/django/_searches"

  search_types="adminaircraft briefingt contracts data dataprops experiment grants nap5 qpnotes travela travelq"

  # drop database and re-create
  printf "${SPACER}${Cyan}${INDENT}Remaking fresh database...${NC}${EOL}"
  psql -v ON_ERROR_STOP=0 --username "homestead" --dbname "postgres" <<-EOSQL
    DROP DATABASE og_search_local;
    CREATE DATABASE og_search_local;
    GRANT ALL PRIVILEGES ON DATABASE og_search_local TO homestead;
    GRANT ALL PRIVILEGES ON DATABASE og_search_local TO homestead_reader;
EOSQL

  # activate python environment
  . ${APP_ROOT}/django/bin/activate
  if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Activate Python environment: OK${NC}${EOL}"
  else
      printf "${Red}${INDENT}${INDENT}Activate Python environment: FAIL${NC}${EOL}"
  fi

  # run intitial database migrations
  printf "${Cyan}${INDENT}${INDENT}Running initial database migrations...${NC}${EOL}"
  cd ${APP_ROOT}/django/src/oc-search
  python manage.py makemigrations search
  python manage.py sqlmigrate search 0001
  python manage.py migrate
  cd ${APP_ROOT}

  # run import_search
  cd ${APP_ROOT}/django/src/oc-search
  for type in $search_types; do
    python manage.py import_search --import_dir ${searches_import_dir} --search ${type} --include_db
  done
  cd ${APP_ROOT}

  # decativate python environment
  deactivate
  if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
  else
      printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
  fi

  # set ownership
  cd ${APP_ROOT}/django
  chown django:django -R ${APP_ROOT}/django
  printf "${SPACER}"
  if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}Set django ownership to django:django: OK${NC}${EOL}"
  else
      printf "${Red}${INDENT}Set django ownership to django:django: FAIL${NC}${EOL}"
  fi

fi
# END
# Download required search files and install them into the App
# END
