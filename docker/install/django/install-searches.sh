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

  # download oc_searches repo from https://github.com/thriuin/oc_searches
  printf "${SPACER}${Cyan}${INDENT}Downloading search files from https://github.com/thriuin/oc_searches to temporary directory${NC}${EOL}"
  mkdir -p ${APP_ROOT}/django/tmp
  cd ${APP_ROOT}/django/tmp
  wget https://github.com/thriuin/oc_searches/archive/refs/heads/main.zip
  unzip main.zip
  tmp_dir="${APP_ROOT}/django/tmp/oc_searches-main"

  search_types="adminaircraft briefingt contracts data dataprops experiment grants nap5 qpnotes travela travelq"

  # copy plugin files
  printf "${SPACER}${Cyan}${INDENT}Copying plugin files...${NC}${EOL}"
  function copy_plugin_files() {

    search_type="$1"
    printf "${Cyan}${INDENT}${INDENT}Copying plugin files for ${search_type}${NC}${EOL}"

    if [[ ! -f "${tmp_dir}/${search_type}/plugins/${search_type}.py" ]]; then

      printf "${Yellow}${INDENT}${INDENT}${search_type} has no plugin file: SKIPPING${NC}${EOL}"

    else

      cp ${tmp_dir}/${search_type}/plugins/${search_type}.py ${APP_ROOT}/django/src/oc-search/search/plugins/${search_type}.py

      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy plugins/${search_type}.py: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy plugins/${search_type}.py: FAIL${NC}${EOL}"
      fi

    fi

  }

  for type in $search_types; do
    copy_plugin_files $type
  done
  # END copy plugin files END

  # copy custom snippet files
  printf "${SPACER}${Cyan}${INDENT}Copying snippet files...${NC}${EOL}"
  function copy_snippet_files() {

    search_type="$1"
    printf "${Cyan}${INDENT}${INDENT}Copying snippet files for ${search_type}${NC}${EOL}"

    if [[ ! -d "${APP_ROOT}/django/src/oc-search/search/templates/snippets/custom/${search_type}" ]]; then

      mkdir -p ${APP_ROOT}/django/src/oc-search/search/templates/snippets/custom/${search_type}

    fi

    cp ${tmp_dir}/${search_type}/snippets/* ${APP_ROOT}/django/src/oc-search/search/templates/snippets/custom/${search_type}/

    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Copy ${search_type}/snippets: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Copy ${search_type}/snippets: FAIL${NC}${EOL}"
    fi

  }

  for type in $search_types; do
    copy_snippet_files $type
  done
  # END copy custom snippet files END

  # copy command files
  printf "${SPACER}${Cyan}${INDENT}Copying command files...${NC}${EOL}"
  function copy_command_files() {

    search_type="$1"
    printf "${Cyan}${INDENT}${INDENT}Copying command files for ${search_type}${NC}${EOL}"

    if [[ ! -d "${tmp_dir}/${search_type}/commands" ]]; then

      printf "${Yellow}${INDENT}${INDENT}${search_type} has no command files: SKIPPING${NC}${EOL}"

    else

      cp ${tmp_dir}/${search_type}/commands/* ${APP_ROOT}/django/src/oc-search/search/management/commands/

      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ${search_type}/commands: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ${search_type}/commands: FAIL${NC}${EOL}"
      fi

    fi

  }

  for type in $search_types; do
    copy_command_files $type
  done
  # END copy command files END

  # copy locale files
  printf "${SPACER}${Cyan}${INDENT}Copying locale files...${NC}${EOL}"
  function copy_locale_files() {

    search_type="$1"
    printf "${Cyan}${INDENT}${INDENT}Copying command files for ${search_type}${NC}${EOL}"

    if [[ ! -f "${tmp_dir}/${search_type}/locale/${search_type}.po" ]]; then

      printf "${Yellow}${INDENT}${INDENT}${search_type} has no locale files: SKIPPING${NC}${EOL}"

    else

      cp ${tmp_dir}/${search_type}/locale/${search_type}.po ${APP_ROOT}/django/src/oc-search/locale/fr/LC_MESSAGES/${search_type}.po

      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy locale/${search_type}.po: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy locale/${search_type}.po: FAIL${NC}${EOL}"
      fi

    fi

  }

  for type in $search_types; do
    copy_locale_files $type
  done
  # END copy locale files END

  # copy database files
  printf "${SPACER}${Cyan}${INDENT}Copying database files...${NC}${EOL}"
  function copy_database_files() {

    search_type="$1"
    printf "${Cyan}${INDENT}${INDENT}Copying database files for ${search_type}${NC}${EOL}"

    if [[ ! -d "${tmp_dir}/${search_type}/db" ]]; then

      printf "${Yellow}${INDENT}${INDENT}${search_type} has no database files: SKIPPING${NC}${EOL}"

    else

      cp ${tmp_dir}/${search_type}/db/* ${APP_ROOT}/django/src/oc-search/data/
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ${search_type}/db: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ${search_type}/db: FAIL${NC}${EOL}"
      fi

    fi

  }

  for type in $search_types; do
    copy_database_files $type
  done
  # END copy database files END

  # cleanup tmp directory
  printf "${SPACER}${Cyan}${INDENT}Cleaning up temporary directory${NC}${EOL}"
  rm -rf ${APP_ROOT}/django/tmp
  if [[ $? -eq 0 ]]; then
    printf "${Green}${INDENT}Cleanup django/tmp: OK${NC}${EOL}"
  else
    printf "${Red}${INDENT}Cleanup django/tmp: FAIL${NC}${EOL}"
  fi

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

  printf "${Cyan}${INDENT}${INDENT}Running initial database migrations...${NC}${EOL}"
  cd ${APP_ROOT}/django/src/oc-search
  python manage.py makemigrations search
  python manage.py sqlmigrate search 0001
  python manage.py migrate
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
