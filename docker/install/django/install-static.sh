#!/bin/bash

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