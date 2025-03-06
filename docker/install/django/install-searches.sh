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

  search_types="adminaircraft ati atimap briefingt cafcip contracts data dataprops datastrategy experiment grants hospitalityq nap5 qpnotes reclassification travela travelq wrongdoing"

  # download yaml config files
  printf "${SPACER}${Cyan}${INDENT}Download CKAN config files${NC}${EOL}"
  mkdir -p ${APP_ROOT}/django/ckan_config_files
  cd ${APP_ROOT}/django/ckan_config_files
  wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/schemas/presets.yaml
  wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/schemas/prop.yaml
  wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/choices/minister.json
  for type in $search_types; do
    wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/${type}.yaml
  done
  cd ${APP_ROOT}

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
  cd ${APP_ROOT}/django/src/oc_search
  python manage.py makemigrations search
  python manage.py sqlmigrate search 0001
  python manage.py migrate
  cd ${APP_ROOT}

  # import search definitions
  cd ${APP_ROOT}/django/src/oc_search
  printf "${Cyan}${INDENT}${INDENT}Importing search definitions...${NC}${EOL}"
  for type in $search_types; do
    python manage.py import_search --include_db --import_dir ${APP_ROOT}/django/src/oc_searches/ --search ${type}
  done
  cd ${APP_ROOT}

  # create solr schemas
  cd ${APP_ROOT}/django/src/oc_search
  printf "${Cyan}${INDENT}${INDENT}Creating SOLR schemas from search definitions...${NC}${EOL}"
  for type in $search_types; do
    printf "${Cyan}${INDENT}${INDENT}Creating SOLR schemas from search definition ${type}${NC}${EOL}"
    python manage.py create_solr_core --search ${type}
  done
  cd ${APP_ROOT}

  # create a super user
  DJANGO_SUPERUSER_USERNAME='admin_local'
  DJANGO_SUPERUSER_PASSWORD='12345678'
  DJANGO_SUPERUSER_EMAIL='temp@tbs-sct.gc.ca'
  cd ${APP_ROOT}/django/src/oc_search
  python manage.py createsuperuser --noinput --username ${DJANGO_SUPERUSER_USERNAME} --email ${DJANGO_SUPERUSER_EMAIL}

  # download nltk stuff
  cd ${APP_ROOT}/django/src/oc_search
  printf "${Cyan}${INDENT}${INDENT}Downloading NLTK dependencies...${NC}${EOL}"
  python manage.py nltk_download
  cd ${APP_ROOT}

  # collect static files
  cd ${APP_ROOT}/django/src/oc_search
  printf "${Cyan}${INDENT}${INDENT}Collecting static files and templates...${NC}${EOL}"
  python manage.py collectstatic --no-input
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
