#!/bin/bash

printf "${SPACER}${Cyan}${INDENT}Select what to install for ${BOLD}CKAN:${HAIR}${NC}${SPACER}"

if [[ $CKAN_ROLE == 'registry' ]]; then

  # Options for the user to select from
  options=(
    "Registry Database" 
    "Registry Datastore Database" 
    "Repositories (Installs them into Python venv ckan/${CKAN_ROLE})" 
    "Download Wet-Boew Files" 
    "Set File Permissions" 
    "Create Local User" 
    "Import Organizations" 
    "Import Datasets" 
    "All" 
    "Exit"
  )

elif [[ $CKAN_ROLE == 'portal' ]]; then

  # Options for the user to select from
  options=(
    "Portal Database" 
    "Portal Datastore Database" 
    "Repositories (Installs them into Python venv ckan/${CKAN_ROLE})" 
    "Download Wet-Boew Files" 
    "Set File Permissions" 
    "Create Local User" 
    "Import Organizations" 
    "Import Datasets" 
    "All" 
    "Exit"
  )

fi

# IMPORTANT: select_option will return the index of the options and not the value.
select_option "${options[@]}"
opt=$?

case $opt in

  # "Registry Database / Portal Database"
  (0) 
    exitScript='false'
    if [[ $CKAN_ROLE == 'registry' ]]; then
      installDB_Registry_CKAN='true'
      installDB_Portal_CKAN='false'
    elif [[ $CKAN_ROLE == 'portal' ]]; then
      installDB_Portal_CKAN='true'
      installDB_Registry_CKAN='false'
    fi
    ;;

  # "Registry Datastore Database / Portal Datastore Database"
  (1) 
    exitScript='false'
    if [[ $CKAN_ROLE == 'registry' ]]; then
      installDB_Registry_DS_CKAN='true'
      installDB_Portal_DS_CKAN='false'
    elif [[ $CKAN_ROLE == 'portal' ]]; then
      installDB_Portal_DS_CKAN='true'
      installDB_Registry_DS_CKAN='false'
    fi
    ;;

  # "Repositories (Installs them into Python venv)"
  (2) 
    exitScript='false'
    installRepos_CKAN='true'
    ;;

  # "Download Wet-Boew Files"
  (3)
    exitScript='false'
    installTheme_CKAN='true'
    ;;


  # "Set File Permissions"
  (4)
    exitScript='false'
    installFilePermissions_CKAN='true'
    ;;

  # "Create Local User"
  (5)
    exitScript='false'
    installLocalUser_CKAN='true'
    ;;

  # "Import Organizations"
  (6)
    exitScript='false'
    installOrgs_CKAN='true'
    ;;

  # "Import Datasets"
  (7)
    exitScript='false'
    installDatasets_CKAN='true'
    ;;

  # "All"
  (8) 
    exitScript='false'
    if [[ $CKAN_ROLE == 'registry' ]]; then
      installDB_Registry_CKAN='true'
      installDB_Registry_DS_CKAN='true'
      installDB_Portal_CKAN='false'
      installDB_Portal_DS_CKAN='false'
    elif [[ $CKAN_ROLE == 'portal' ]]; then
      installDB_Portal_CKAN='true'
      installDB_Portal_DS_CKAN='true'
      installDB_Registry_CKAN='false'
      installDB_Registry_DS_CKAN='false'
    fi
    installRepos_CKAN='true'
    installFilePermissions_CKAN='true'
    installLocalUser_CKAN='true'
    installOrgs_CKAN='true'
    installDatasets_CKAN='true'
    ;;

  # "Exit"
  (10)
    exitScript='true'
    ;;

esac

#
# Run Script
#
if [[ $exitScript != "true" ]]; then

  #
  # Confirm CKAN Portal database destruction
  #
  if [[ $installDB_Portal_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Portal database\033[0m\033[0;31m and import a fresh copy? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

      installDB_Portal_CKAN='true'

    else

      installDB_Portal_CKAN='false'

    fi

  fi
  # END
  # Confirm CKAN Portal database destruction
  # END

  #
  # Confirm CKAN Portal Datastore database destruction
  #
  if [[ $installDB_Portal_DS_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Portal Datastore database\033[0m\033[0;31m and import a fresh copy? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

      installDB_Portal_DS_CKAN='true'

    else

      installDB_Portal_DS_CKAN='false'

    fi

  fi
  # END
  # Confirm CKAN Portal Datastore database destruction
  # END

  #
  # Confirm CKAN Registry database destruction
  #
  if [[ $installDB_Registry_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Registry database\033[0m\033[0;31m and import a fresh copy? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

      installDB_Registry_CKAN='true'

    else

      installDB_Registry_CKAN='false'

    fi

  fi
  # END
  # Confirm CKAN Registry database destruction
  # END

  #
  # Confirm CKAN Registry Datastore database destruction
  #
  if [[ $installDB_Registry_DS_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Registry Datastore database\033[0m\033[0;31m and import a fresh copy? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

      installDB_Registry_DS_CKAN='true'

    else

      installDB_Registry_DS_CKAN='false'

    fi

  fi
  # END
  # Confirm CKAN Registry Datase database destruction
  # END

  #
  # Confirm CKAN repo destruction
  #
  if [[ $installRepos_CKAN == "true" ]]; then

    if [[ $CKAN_ROLE == 'registry' ]]; then
      
      read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Registry directory (ckan/registry)\033[0m\033[0;31m and pull fast-forwarded repositories and install them into the Python environment? [y/N]:\033[0;0m    ' response

    elif [[ $CKAN_ROLE == 'portal' ]]; then
      
      read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Portaly directory (ckan/portal)\033[0m\033[0;31m and pull fast-forwarded repositories and install them into the Python environment? [y/N]:\033[0;0m    ' response
      
    fi

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
  # Confirm CKAN Wet-Boew repo archive destruction
  #
  if [[ $installTheme_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want delete the\033[1m existing CKAN Wet-Boew directory (ckan/static_files)\033[0m\033[0;31m and download new files? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

      installTheme_CKAN='true'

    else

      installTheme_CKAN='false'

    fi

  fi
  # END
  # Confirm CKAN Wet-Boew repo archive destruction
  # END

  #
  # Confirm CKAN Organizations re-import
  #
  if [[ $installOrgs_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want to re-import all of the\033[1m CKAN Organizations\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

      installOrgs_CKAN='true'

    else

      installOrgs_CKAN='false'

    fi

  fi
  # END
  # Confirm CKAN Organizations re-import
  # END

  #
  # Confirm CKAN Datasets re-import
  #
  if [[ $installDatasets_CKAN == "true" ]]; then

    read -r -p $'\n\n\033[0;31m    Are you sure you want to re-import all of the\033[1m CKAN Datasets\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

      installDatasets_CKAN='true'

    else

      installDatasets_CKAN='false'

    fi

  fi
  # END
  # Confirm CKAN Datasets re-import
  # END

  #
  # Destroy and re-import portal database
  #
  if [[ $installDB_Portal_CKAN == "true" ]]; then

    if [[ -f "${APP_ROOT}/backup/ckan_portal_db.pgdump" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_portal_local__${PROJECT_ID} DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
      psql -eb --dbname=og_ckan_portal_local__${PROJECT_ID} --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_portal_local__${PROJECT_ID} TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

      # import the database
      printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_portal_local__${PROJECT_ID}${HAIR}${NC}${SPACER}"
      pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_portal_local__${PROJECT_ID} --username=$PGUSER ${APP_ROOT}/backup/ckan_portal_db.pgdump

    else

      printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_portal_local__${PROJECT_ID} DB${HAIR}${Orange} import, backup/ckan_portal_db.pgdump does not exist.${NC}${SPACER}"

    fi

  fi
  # END
  # Destroy and re-import portal database
  # END

  #
  # Destroy and re-import portal datastore database
  #
  if [[ $installDB_Portal_DS_CKAN == "true" ]]; then

    if [[ -f "${APP_ROOT}/backup/ckan_portal_ds_db.pgdump" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_portal_ds_local__${PROJECT_ID} DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
      psql -eb --dbname=og_ckan_portal_ds_local__${PROJECT_ID} --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_portal_ds_local__${PROJECT_ID} TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

      # import the database
      printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_portal_ds_local__${PROJECT_ID}${HAIR}${NC}${SPACER}"
      pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_portal_ds_local__${PROJECT_ID} --username=$PGUSER ${APP_ROOT}/backup/ckan_portal_ds_db.pgdump

    else

      printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_portal_ds_local__${PROJECT_ID} DB${HAIR}${Orange} import, backup/ckan_portal_ds_db.pgdump does not exist.${NC}${SPACER}"

    fi

  fi
  # END
  # Destroy and re-import portal datastore database
  # END

  #
  # Destroy and re-import registry database
  #
  if [[ $installDB_Registry_CKAN == "true" ]]; then

    if [[ -f "${APP_ROOT}/backup/ckan_registry_db.pgdump" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_registry_local__${PROJECT_ID} DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
      psql -eb --dbname=og_ckan_registry_local__${PROJECT_ID} --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_registry_local__${PROJECT_ID} TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

      # import the database
      printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_registry_local__${PROJECT_ID}${HAIR}${NC}${SPACER}"
      pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_registry_local__${PROJECT_ID} --username=$PGUSER ${APP_ROOT}/backup/ckan_registry_db.pgdump

    else

      printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_registry_local__${PROJECT_ID} DB${HAIR}${Orange} import, backup/ckan_registry_db.pgdump does not exist.${NC}${SPACER}"

    fi

  fi
  # END
  # Destroy and re-import registry database
  # END

  #
  # Destroy and re-import registry datastore database
  #
  if [[ $installDB_Registry_DS_CKAN == "true" ]]; then

    if [[ -f "${APP_ROOT}/backup/ckan_registry_ds_db.pgdump" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Drop the ${BOLD}og_ckan_registry_ds_local__${PROJECT_ID} DB${HAIR}${Cyan} if it exists and then recreate it blank/clean${NC}${SPACER}"
      psql -eb --dbname=og_ckan_registry_ds_local__${PROJECT_ID} --username=$PGUSER --command="DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON DATABASE og_ckan_registry_ds_local__${PROJECT_ID} TO homestead; GRANT ALL ON SCHEMA public TO homestead;"

      # import the database
      printf "${SPACER}${Cyan}${INDENT}Import the database from the pg_dump backup into ${BOLD}og_ckan_registry_ds_local__${PROJECT_ID}${HAIR}${NC}${SPACER}"
      pg_restore -v --clean --if-exists --exit-on-error --no-privileges --no-owner --dbname=og_ckan_registry_ds_local__${PROJECT_ID} --username=$PGUSER ${APP_ROOT}/backup/ckan_registry_ds_db.pgdump

    else

      printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}og_ckan_registry_ds_local__${PROJECT_ID} DB${HAIR}${Orange} import, backup/ckan_registry_ds_db.pgdump does not exist.${NC}${SPACER}"

    fi

  fi
  # END
  # Destroy and re-import registry datastore database
  # END

  #
  # Destroy and pull and install fast-forwarded repositories
  #
  if [[ $installRepos_CKAN == "true" ]]; then

    mkdir -p ${APP_ROOT}/ckan/${CKAN_ROLE}

    # nuke the entire folder
    printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing CKAN (${CKAN_ROLE}) install${NC}${SPACER}"
    # destroy all files
    cd ${APP_ROOT}/ckan/${CKAN_ROLE}
    rm -rf ./*
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Remove all files in ckan/${CKAN_ROLE}: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Remove all files in ckan/${CKAN_ROLE}: FAIL${NC}${EOL}"
    fi
    cd ${APP_ROOT}/ckan/${CKAN_ROLE}
    rm -rf ./.??*
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Remove all hidden files in ckan/${CKAN_ROLE}: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Remove all hidden files in ckan/${CKAN_ROLE}: FAIL${NC}${EOL}"
    fi

    # create virtual environment
    virtualenv --python=python2 ${APP_ROOT}/ckan/${CKAN_ROLE}
    cd ${APP_ROOT}/ckan/${CKAN_ROLE}

    # set ownership
    chown ckan:ckan -R ${APP_ROOT}/ckan/${CKAN_ROLE}
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: FAIL${NC}${EOL}"
    fi

    # activate python environment
    . ${APP_ROOT}/ckan/${CKAN_ROLE}/bin/activate
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Activate Python environment: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Activate Python environment: FAIL${NC}${EOL}"
    fi
    # install setup tools
    pip install setuptools==${SETUP_TOOLS_VERSION}
    # update pip
    pip install --upgrade pip==${PIP_VERSION}
    # install uwsgi
    pip install uwsgi
    # install future
    pip install future==0.18.2
    # update certifi
    pip install --upgrade certifi
    # install correct version of cryptography
    pip install cryptography==2.2.2

    # install ckan core into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Core repository${HAIR}${Cyan} from https://github.com:open-data/ckan.git@canada-v2.8 and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckan.git@canada-v2.8#egg=ckan' -r 'https://raw.githubusercontent.com/open-data/ckan/canada-v2.8/requirements.txt' -r 'https://raw.githubusercontent.com/open-data/ckan/canada-v2.8/dev-requirements.txt'

    # install ckanapi into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN API repository${HAIR}${Cyan} from https://github.com:ckan/ckanapi.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/ckan/ckanapi.git#egg=ckanapi' -r 'https://raw.githubusercontent.com/ckan/ckanapi/master/requirements.txt'

    # install ckan canada into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Canada repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-canada.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-canada.git#egg=ckanext-canada' -r 'https://raw.githubusercontent.com/open-data/ckanext-canada/master/requirements.txt'

    # install ckan cloud storage into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Cloud Storage repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-cloudstorage.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-cloudstorage.git#egg=ckanext-cloudstorage'

    # install ckan dcat into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN DCat repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-dcat.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-dcat.git#egg=ckanext-dcat' -r 'https://raw.githubusercontent.com/open-data/ckanext-dcat/master/requirements.txt'

    # install ckan extended activity into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Extended Activity${HAIR}${Cyan} repository from https://github.com:open-data/ckanext-extendedactivity.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-extendedactivity.git#egg=ckanext-extendedactivity'

    # install ckan extractor into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Extractor repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-extractor.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-extractor.git#egg=ckanext-extractor' -r 'https://raw.githubusercontent.com/open-data/ckanext-extractor/master/requirements.txt'

    # install ckan fluent into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Fluent repository${HAIR}${Cyan} from https://github.com:ckan/ckanext-fluent.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/ckan/ckanext-fluent.git#egg=ckanext-fluent' -r 'https://raw.githubusercontent.com/ckan/ckanext-fluent/master/requirements.txt'

    # install ckan recombinant into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Recombinant repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-recombinant.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-recombinant.git#egg=ckanext-recombinant' -r 'https://raw.githubusercontent.com/open-data/ckanext-recombinant/master/requirements.txt'

    # install ckan scheming into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Scheming repository${HAIR}${Cyan} from https://github.com:ckan/ckanext-scheming.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/ckan/ckanext-scheming.git#egg=ckanext-scheming'

    # install ckan security into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Security repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-security@canada-v2.8.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-security.git@canada-v2.8#egg=ckanext-security'

    # install ckan validation into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Validation repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-validation.git@canada and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-validation.git@canada#egg=ckanext-validation' -r 'https://raw.githubusercontent.com/open-data/ckanext-validation/canada/requirements.txt' -r 'https://raw.githubusercontent.com/open-data/ckanext-validation/canada/dev-requirements.txt'

    # install ckan xloader into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Xloader repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-xloader.git@canada-v2.8  and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-xloader.git@canada-v2.8#egg=ckanext-xloader' -r 'https://raw.githubusercontent.com/open-data/ckanext-xloader/canada-v2.8/requirements.txt' -r 'https://raw.githubusercontent.com/open-data/ckanext-xloader/canada-v2.8/dev-requirements.txt'

    # install ckantoolkit into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Toolkit repository${HAIR}${Cyan} from https://github.com:ckan/ckantoolkit.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/ckan/ckantoolkit.git#egg=ckantoolkit' -r 'https://raw.githubusercontent.com/ckan/ckantoolkit/master/requirements.txt'

    # install goodtables into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}Goodtables repository${HAIR}${Cyan} from https://github.com:open-data/goodtables.git@canada and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/goodtables.git@canada#egg=goodtables' -r 'https://raw.githubusercontent.com/open-data/goodtables/canada/requirements.txt'

    # install ckan wet boew into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Wet-Boew repository${HAIR}${Cyan} from https://ithub.com:open-data/ckanext-wet-boew.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-wet-boew.git#egg=ckanext-wet-boew' -r 'https://raw.githubusercontent.com/open-data/ckanext-wet-boew/master/requirements.txt'

    # install flask admin
    pip install Flask-Admin==1.4.0

    # install flask login
    pip install Flask-Login==0.3.0

    # install flask sql alchemy
    pip install Flask-SQLAlchemy==2.5.1

    # install correct version of slugify
    pip install python-slugify==1.2.0

    # install request with security modules
    pip install requests[security]==2.11.1

    # install correct version of cryptography
    pip install cryptography==2.2.2

    # install correct version of sqlalchemy
    pip install sqlalchemy==1.3.5

    # update vdm
    pip install --upgrade vdm

    # install nltk punkt
    if [[ $CKAN_ROLE == 'portal' ]]; then
      printf "${SPACER}${Cyan}${INDENT}Installing nltk.punkt into ${CKAN_ROLE} environment${NC}${SPACER}"
      python2 -c "import nltk; nltk.download('punkt');"
    else
      printf "${SPACER}${Cyan}${INDENT}Skipping nltk.punkt installation for ${CKAN_ROLE} environment${NC}${SPACER}"
    fi

    # copy local ckan config file
    cp ${APP_ROOT}/_config/ckan/${CKAN_ROLE}.ini ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini
    printf "${SPACER}${Cyan}${INDENT}Copying local ${CKAN_ROLE} config file to into Python environment${NC}${SPACER}"
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Copy ${CKAN_ROLE}.ini to ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Copy ${CKAN_ROLE}.ini to ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini: FAIL${NC}${EOL}"
    fi

    # copy core who config file
    cp ${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckan/ckan/config/who.ini ${APP_ROOT}/ckan/${CKAN_ROLE}/who.ini
    printf "${SPACER}${Cyan}${INDENT}Copying Core CKAN who config file to into root Python environment${NC}${SPACER}"
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Copy ckan/${CKAN_ROLE}/src/ckan/ckan/config/who.ini to ckan/${CKAN_ROLE}/who.ini: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Copy ckan/${CKAN_ROLE}/src/ckan/ckan/config/who.ini to ckan/${CKAN_ROLE}/who.ini: FAIL${NC}${EOL}"
    fi

    # create i18n directory
    mkdir -p /srv/app/ckan/${CKAN_ROLE}/src/ckanext-canada/build
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Create /srv/app/ckan/${CKAN_ROLE}/src/ckanext-canada/build: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Create /srv/app/ckan/${CKAN_ROLE}/src/ckanext-canada/build: FAIL (directory may already exist)${NC}${EOL}"
    fi

    # generate translation files
    cd /srv/app/ckan/${CKAN_ROLE}/src/ckanext-canada/bin
    . build-combined-ckan-mo.sh

    # decativate python environment
    deactivate
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
    fi

    # create storage path
    printf "${SPACER}${Cyan}${INDENT}Create storage path${NC}${SPACER}"
    mkdir -p ${APP_ROOT}/ckan/${CKAN_ROLE}/storage
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Create ckan/${CKAN_ROLE}/storage: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Create ckan/${CKAN_ROLE}/storage: FAIL (directory may already exist)${NC}${EOL}"
    fi

    # copy ckanext-canada static files to static_files
    printf "${SPACER}${Cyan}${INDENT}Copy CKAN Canada static files${NC}${SPACER}"
    cp -R ${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/static ${APP_ROOT}/ckan/static_files/
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/static to ${APP_ROOT}/ckan/static_files/static: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/static to ${APP_ROOT}/ckan/static_files/static: FAIL${NC}${EOL}"
    fi
    chown -R ckan:ckan ${APP_ROOT}/ckan/static_files/static

    # copy ckanext-canada data files to static_files
    if [[ -d "${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/data" ]]; then
      printf "${SPACER}${Cyan}${INDENT}Copy CKAN Canada data files${NC}${SPACER}"
      cp -R ${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/data ${APP_ROOT}/ckan/static_files/
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/data to ${APP_ROOT}/ckan/static_files/data: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/data to ${APP_ROOT}/ckan/static_files/data: FAIL${NC}${EOL}"
      fi
    fi;
    chown -R ckan:ckan ${APP_ROOT}/ckan/static_files/data

    # copy wsgi files
    printf "${SPACER}${Cyan}${INDENT}Copy ${CKAN_ROLE} wsgi config file to virtual environment${NC}${SPACER}"
    cp ${APP_ROOT}/docker/config/ckan/wsgi/${CKAN_ROLE}.py ${APP_ROOT}/ckan/${CKAN_ROLE}/wsgi.py
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Copy ${APP_ROOT}/docker/config/ckan/wsgi/${CKAN_ROLE}.py to ${APP_ROOT}/ckan/${CKAN_ROLE}/wsgi.py: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Copy ${APP_ROOT}/docker/config/ckan/wsgi/${CKAN_ROLE}.py to ${APP_ROOT}/ckan/${CKAN_ROLE}/wsgi.py: FAIL${NC}${EOL}"
    fi

    # set ownership
    chown ckan:ckan -R ${APP_ROOT}/ckan/${CKAN_ROLE}
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: FAIL${NC}${EOL}"
    fi

  fi
  # END
  # Destroy and pull and install fast-forwarded repositories
  # END

  #
  # Download Wet-Boew repo archives for CKAN
  #
  if [[ $installTheme_CKAN == "true" ]]; then

    mkdir -p ${APP_ROOT}/ckan/static_files
    cd ${APP_ROOT}/ckan/static_files

    # nuke the entire folder
    printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing CKAN Static Files directory${NC}${SPACER}"
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

    # download wet-boew/wet-boew-cdn
    mkdir -p ${APP_ROOT}/ckan/static_files/wet-boew
    curl -L https://github.com/wet-boew/wet-boew-cdn/archive/${WET_VERSION}.tar.gz | tar -zvx --strip-components 1 --directory=${APP_ROOT}/ckan/static_files/wet-boew

    # download wet-boew/themes-cdn
    mkdir -p ${APP_ROOT}/ckan/static_files/GCWeb
    curl -L https://github.com/wet-boew/themes-cdn/archive/${GCWEB_VERSION}-gcweb.tar.gz | tar -zvx --strip-components 1 --directory=${APP_ROOT}/ckan/static_files/GCWeb

    # copy ckanext-canada static files to static_files
    if [[ -d "${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/static" ]]; then
      printf "${SPACER}${Cyan}${INDENT}Copy CKAN Canada static files${NC}${SPACER}"
      cp -R ${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/static ${APP_ROOT}/ckan/static_files/
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/static to ${APP_ROOT}/ckan/static_files/static: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/static to ${APP_ROOT}/ckan/static_files/static: FAIL${NC}${EOL}"
      fi
    fi;

    # copy ckanext-canada data files to static_files
    if [[ -d "${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/data" ]]; then
      printf "${SPACER}${Cyan}${INDENT}Copy CKAN Canada data files${NC}${SPACER}"
      cp -R ${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/data ${APP_ROOT}/ckan/static_files/
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/data to ${APP_ROOT}/ckan/static_files/data: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}${APP_ROOT}/ckan/${CKAN_ROLE}/src/ckanext-canada/ckanext/canada/public/data to ${APP_ROOT}/ckan/static_files/data: FAIL${NC}${EOL}"
      fi
    fi;

    chown -R ckan:ckan ${APP_ROOT}/ckan/static_files

  fi
  # END
  # Pull Wet-Boew repos for CKAN
  # END

  #
  # Set file permissions
  #
  if [[ $installFilePermissions_CKAN == "true" ]]; then

    # set file ownership for ckan files
    chown ckan:ckan -R ${APP_ROOT}/ckan/${CKAN_ROLE}
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Set ckan/${CKAN_ROLE} ownership to ckan:ckan: FAIL${NC}${EOL}"
    fi

    # set file ownership for ckan static files
    chown ckan:ckan -R ${APP_ROOT}/ckan/static_files
    if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}${INDENT}Set ckan/static_files ownership to ckan:ckan: OK${NC}${EOL}"
    else
      printf "${Red}${INDENT}${INDENT}Set ckan/static_files ownership to ckan:ckan: FAIL${NC}${EOL}"
    fi

    # initialize databases
    paster --plugin=ckan db init -c ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini

    # set database permissions
    paster --plugin=ckan datastore set-permissions -c ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini | psql -U homestead --set ON_ERROR_STOP=1

  fi
  # END
  # Set file permissions
  # END

  #
  # Create local user
  #
  if [[ $installLocalUser_CKAN == "true" ]]; then

    if [[ $CKAN_ROLE == 'registry' ]]; then

      # create member user
      printf "${SPACER}${Cyan}${INDENT}Create default user${NC}${SPACER}"
      paster --plugin=ckan user add user_local email=temp+user@tbs-sct.gc.ca password=12345678 -c $REGISTRY_CONFIG

      # create system admin
      printf "${SPACER}${Cyan}${INDENT}Create system admin user${NC}${SPACER}"
      paster --plugin=ckan user add admin_local email=temp@tbs-sct.gc.ca password=12345678 -c $REGISTRY_CONFIG
      paster --plugin=ckan sysadmin -c $REGISTRY_CONFIG -v add admin_local password=12345678 email=temp@tbs-sct.gc.ca

    elif [[ $CKAN_ROLE == 'portal' ]]; then

      # create member user
      printf "${SPACER}${Cyan}${INDENT}Create default user${NC}${SPACER}"
      paster --plugin=ckan user add user_local email=temp+user@tbs-sct.gc.ca password=12345678 -c $PORTAL_CONFIG

      # create system admin
      printf "${SPACER}${Cyan}${INDENT}Create system admin user${NC}${SPACER}"
      paster --plugin=ckan user add admin_local email=temp@tbs-sct.gc.ca password=12345678 -c $PORTAL_CONFIG
      paster --plugin=ckan sysadmin -c $PORTAL_CONFIG -v add admin_local password=12345678 email=temp@tbs-sct.gc.ca

    fi

  fi
  # END
  # Create local user
  # END

  #
  # Import Organizations
  #
  if [[ $installOrgs_CKAN == "true" ]]; then

    # remove old orgs file
    printf "${SPACER}${Cyan}${INDENT}Remove old orgs.jsonl file${NC}${SPACER}"
    rm -rf ${APP_ROOT}/backup/orgs.jsonl

    # dump new orgs
    printf "${SPACER}${Cyan}${INDENT}Dump latest Organizations into orgs.jsonl file${NC}${SPACER}"
    ckanapi dump organizations --all -r https://open.canada.ca/data -O ${APP_ROOT}/backup/orgs.jsonl
    chown ckan:ckan ${APP_ROOT}/backup/orgs.jsonl

    # import the orgs
    printf "${SPACER}${Cyan}${INDENT}Import Organizations${NC}${SPACER}"
    ckanapi load organizations -I ${APP_ROOT}/backup/orgs.jsonl -c ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini

  fi
  # END
  # Import Organizations
  # END

  #
  # Import Datasets
  #
  if [[ $installDatasets_CKAN == "true" ]]; then

    # remove old datasets file
    printf "${SPACER}${Cyan}${INDENT}Remove old Datasets file${NC}${SPACER}"
    rm -rf ${APP_ROOT}/backup/od-do-canada.jsonl.gz

    # download new datasets
    printf "${SPACER}${Cyan}${INDENT}Download new Datasets file${NC}${SPACER}"
    curl --output ${APP_ROOT}/backup/od-do-canada.jsonl.gz https://open.canada.ca/static/od-do-canada.jsonl.gz
    chown ckan:ckan ${APP_ROOT}/backup/od-do-canada.jsonl.gz

    # import the datasets
    printf "${SPACER}${Cyan}${INDENT}Import Datasets${NC}${SPACER}"
    ckanapi load datasets -I ${APP_ROOT}/backup/od-do-canada.jsonl.gz -z -p 16 -c ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini -l ${APP_ROOT}/backup/${CKAN_ROLE}__dataset_import__$(date +%s).log
    chown ckan:ckan ${APP_ROOT}/backup/${CKAN_ROLE}__dataset_import__*.log

  fi
  # END
  # Import Datasets
  # END

else

  printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

fi
# END
# Run Script
# END