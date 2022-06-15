#!/bin/bash

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