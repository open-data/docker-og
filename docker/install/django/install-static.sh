#!/bin/bash

#
# Download static files
#
if [[ $installFiles_Django == "true" ]]; then

    # clear static directory
    if [[ -d "${APP_ROOT}/django/static" ]]; then

      printf "${SPACER}${Cyan}${INDENT}Destroying old static directory...${NC}${SPACER}"
      rm -rf ${APP_ROOT}/django/static

    fi
    printf "${SPACER}${Cyan}${INDENT}Creating static directory...${NC}${SPACER}"
    mkdir -p ${APP_ROOT}/django/static

    # download wet-boew/themes-cdn
    printf "${SPACER}${Cyan}${INDENT}Download the wet-boew theme${NC}${SPACER}"
    mkdir -p ${APP_ROOT}/django/static/themes-dist-GCWeb
    cd ${APP_ROOT}/django/static/themes-dist-GCWeb
    curl -L https://github.com/wet-boew/themes-cdn/archive/${GCWEB_VERSION}-gcweb.tar.gz | tar -zvx --strip-components 1 --directory=${APP_ROOT}/django/static/themes-dist-GCWeb

    # pull the cenw-wscoe/sgdc-cdts repo
    printf "${SPACER}${Cyan}${INDENT}Pull the CDTS repo${NC}${SPACER}"
    mkdir -p ${APP_ROOT}/django/static/cdts/source
    cd ${APP_ROOT}/django/static/cdts/source
    rm -rf ./*
    rm -rf ./.??*
    git clone https://github.com/cenw-wscoe/sgdc-cdts.git .

    # unpack the GCWeb Static release
    printf "${SPACER}${Cyan}${INDENT}Unpack the GCWeb Static release from the CDTS repo${NC}${SPACER}"
    unzip ${APP_ROOT}/django/static/cdts/source/GCWeb/static/Gcwebstatic-${CDTS_GCWEB_VERSION}.zip -d ${APP_ROOT}/django/static/cdts
    cd ${APP_ROOT}/django/static/cdts/static
    mv * ../
    cd ${APP_ROOT}/django/static/cdts
    rm -rf ${APP_ROOT}/django/static/cdts/static

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
