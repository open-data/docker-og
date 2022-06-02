#!/bin/bash

printf "${SPACER}${Cyan}${INDENT}Select what to install for ${BOLD}Django:${HAIR}${NC}${SPACER}"

  # Options for the user to select from
  options=(
    "OGC Django Search App (version 1)" 
    "Static Files" 
    "Set File Permissions" 
    "All" 
    "Exit"
  )

  # IMPORTANT: select_option will return the index of the options and not the value.
  select_option "${options[@]}"
  opt=$?

  case $opt in

    # "OGC Django Search App (version 1)"
    (0) 
      exitScript='false'
      installApp_Django='true'
      ;;

    # "Static Files"
    (1) 
      exitScript='false'
      installFiles_Django='true'
      ;;

    # "Set File Permissions"
    (2)
      exitScript='false'
      installFilePermissions_Django='true'
      ;;

    # "All"
    (3)
      exitScript='false'
      installApp_Django='true'
      installFiles_Django='true'
      installFilePermissions_Django='true'
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

    #
    # Confirm OGC Django App rebuild
    #
    if [[ $installApp_Django == "true" ]]; then

      read -r -p $'\n\n\033[0;31m    Are you sure you want to destroy the current Django install and re-install the\033[1m Python environment and OGC code base\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

      if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installApp_Django='true'

      else

        installApp_Django='false'

      fi

    fi
    # END
    # Confirm CKAN Datasets re-import
    # END

    #
    # Confirm static files download
    #
    if [[ $installFiles_Django == "true" ]]; then

      read -r -p $'\n\n\033[0;31m    Are you sure you want to overwrite the\033[1m static files\033[0m\033[0;31m? [y/N]:\033[0;0m    ' response

      if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

        installFiles_Django='true'

      else

        installFiles_Django='false'

      fi

    fi
    # END
    # Confirm static files download
    # END

    #
    # Install OGC Django App
    #
    if [[ $installApp_Django == "true" ]]; then

      mkdir -p ${APP_ROOT}/django

      # nuke the entire folder
      printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing Django install${NC}${SPACER}"
      # destroy all files
      cd ${APP_ROOT}/django
      rm -rf ./*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all files in django: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all files in django: FAIL${NC}${EOL}"
      fi
      cd ${APP_ROOT}/django
      rm -rf ./.??*
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all hidden files in django: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Remove all hidden files in django: FAIL${NC}${EOL}"
      fi

      # create virtual environment
      python3 -m venv ${APP_ROOT}/django
      cd ${APP_ROOT}/django

      # set ownership
      chown django:django -R ${APP_ROOT}/django
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set django ownership to django:django: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set django ownership to django:django: FAIL${NC}${EOL}"
      fi

      # activate python environment
      . ${APP_ROOT}/django/bin/activate
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Activate Python environment: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Activate Python environment: FAIL${NC}${EOL}"
      fi

      # install setup tools
      pip install --upgrade setuptools
      pip install --upgrade setuptools_rust
      pip install --upgrade rust
      # install wheel
      pip install wheel
      # install py solr
      pip install pysolr
      # update certifi
      pip install --upgrade certifi
      # install correct version of cryptography
      pip install cryptography==2.2.2

      # install ogc search into the python environment
      printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}OGC Search repository${HAIR}${Cyan} from https://github.com:open-data/ogc_search.git and installing into Python environment${NC}${SPACER}"
      pip install -e 'git+https://github.com/open-data/ogc_search.git#egg=ogc_search' -r 'https://raw.githubusercontent.com/open-data/ogc_search/master/requirements.txt'

      # install request with security modules
      pip install requests[security]==2.27.1

      # install correct version of cryptography
      pip install cryptography==2.2.2

      # decativate python environment
      deactivate
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
      fi

      # copy local search settings file
      printf "${SPACER}${Cyan}${INDENT}Copy django config file to virtual environment${NC}${SPACER}"
      cp ${APP_ROOT}/_config/django/settings.py ${APP_ROOT}/django/src/ogc-search/ogc_search/ogc_search/settings.py
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ${APP_ROOT}/_config/django/settings.py to ${APP_ROOT}/django/src/ogc_search/ogc_search/settings.py: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ${APP_ROOT}/_config/django/settings.py to ${APP_ROOT}/django/src/ogc_search/ogc_search/settings.py: FAIL${NC}${EOL}"
      fi

      # download yaml config files
      printf "${SPACER}${Cyan}${INDENT}Download CKAN config files${NC}${SPACER}"
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/ckan_config_files
      cd ${APP_ROOT}/django/src/ogc-search/ogc_search/ckan_config_files
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/schemas/presets.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/briefingt.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/contracts.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/grants.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/nap.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/qpnotes.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/service.yaml
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/tables/choices/minister.json
      wget https://raw.githubusercontent.com/open-data/ckanext-canada/master/ckanext/canada/schemas/prop.yaml

      # set ownership
      cd ${APP_ROOT}/django
      chown django:django -R ${APP_ROOT}/django
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set django ownership to django:django: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set django ownership to django:django: FAIL${NC}${EOL}"
      fi

    fi
    # END
    # Install OGC Django App
    # END

    #
    # Download static files
    #
    if [[ $installFiles_Django == "true" ]]; then

      # download wet-boew/themes-cdn
      printf "${SPACER}${Cyan}${INDENT}Download the wet-boew theme${NC}${SPACER}"
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/themes-dist-GCWeb
      cd ${APP_ROOT}/django/src/ogc-search/ogc_search/themes-dist-GCWeb
      curl -L https://github.com/wet-boew/themes-cdn/archive/${GCWEB_VERSION}-gcweb.tar.gz | tar -zvx --strip-components 1 --directory=${APP_ROOT}/django/src/ogc-search/ogc_search/themes-dist-GCWeb

      # pull the cenw-wscoe/sgdc-cdts repo
      printf "${SPACER}${Cyan}${INDENT}Pull the CDTS repo${NC}${SPACER}"
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts/source
      cd ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts/source
      rm -rf ./*
      rm -rf ./.??*
      git clone https://github.com/cenw-wscoe/sgdc-cdts.git .

      # unpack the GCWeb Static release
      printf "${SPACER}${Cyan}${INDENT}Unpack the GCWeb Static release from the CDTS repo${NC}${SPACER}"
      unzip ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts/source/GCWeb/static/Gcwebstatic-${CDTS_GCWEB_VERSION}.zip -d ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts
      cd ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts/static
      mv * ../
      cd ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts
      rm -rf ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts/static

      # copy static files to static root
      printf "${SPACER}${Cyan}${INDENT}Copy static files to the static root directory${NC}${SPACER}"
      # cdts static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/cdts
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/cdts
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy CDTS static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy CDTS static files: FAIL${NC}${EOL}"
      fi
      rm -rf ${APP_ROOT}/django/src/ogc-search/ogc_search/cdts
      # wet static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/wet
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/wet/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/wet
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy WET static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy WET static files: FAIL${NC}${EOL}"
      fi
      # open data static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/open_data
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/open_data/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/open_data
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Open Data static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Open Data static files: FAIL${NC}${EOL}"
      fi
      # ati static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/ati
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/ATI/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/ati
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ATI static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy ATI static files: FAIL${NC}${EOL}"
      fi
      # briefing notes static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/bn
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/briefing_notes/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/bn
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Briefing Notes static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Briefing Notes static files: FAIL${NC}${EOL}"
      fi
      # contracts static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/ct
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/contracts/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/ct
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Contracts static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Contracts static files: FAIL${NC}${EOL}"
      fi
      # experimental inventory static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/ei
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/experimental_inventory/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/ei
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Experimental Inventory static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Experimental Inventory static files: FAIL${NC}${EOL}"
      fi
      # grant static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/gc
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/grants/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/gc
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Grants static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Grants static files: FAIL${NC}${EOL}"
      fi
      # nap static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/nap
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/national_action_plan/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/nap
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy National Action Plan static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy National Action Plan static files: FAIL${NC}${EOL}"
      fi
      # qp notes static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/qp
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/qp_notes/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/qp
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy QP Notes static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy QP Notes static files: FAIL${NC}${EOL}"
      fi
      # service inventory static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/si
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/service_inventory/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/si
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Service Inventory static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Service Inventory static files: FAIL${NC}${EOL}"
      fi
      # suggested dataset static files
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/sd
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/suggested_dataset/static/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/sd
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy Suggested Dataset static files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy Suggested Dataset static files: FAIL${NC}${EOL}"
      fi
      # GCWeb theme
      mkdir -p ${APP_ROOT}/django/src/ogc-search/ogc_search/static/wxt
      cp -R ${APP_ROOT}/django/src/ogc-search/ogc_search/themes-dist-GCWeb/* ${APP_ROOT}/django/src/ogc-search/ogc_search/static/wxt
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy GCWeb Theme files: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Copy GCWeb Theme files: FAIL${NC}${EOL}"
      fi
      rm -rf ${APP_ROOT}/django/src/ogc-search/ogc_search/themes-dist-GCWeb

      # set ownership
      cd ${APP_ROOT}/django
      chown django:django -R ${APP_ROOT}/django
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set django ownership to django:django: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set django ownership to django:django: FAIL${NC}${EOL}"
      fi

    fi
    # END
    # Download static files
    # END

    #
    # Set ownership
    #
    if [[ $installFilePermissions_Django == "true" ]]; then

      # set ownership
      cd ${APP_ROOT}/django
      chown django:django -R ${APP_ROOT}/django
      if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set django ownership to django:django: OK${NC}${EOL}"
      else
        printf "${Red}${INDENT}${INDENT}Set django ownership to django:django: FAIL${NC}${EOL}"
      fi

    fi
    # END
    # Set ownership
    # END

  else

    printf "${SPACER}${Yellow}${INDENT}Exiting install script...${NC}${SPACER}"

  fi