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

    # activate python environment
    . ${APP_ROOT}/django/bin/activate
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Activate Python environment: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Activate Python environment: FAIL${NC}${EOL}"
    fi

    # make temp cdts dir
    mkdir -p ${APP_ROOT}/django/static/cdts

    # gather static files
    cd ${APP_ROOT}/django/src/oc-search
    python manage.py collectstatic --no-input
    cd ${APP_ROOT}

    # decativate python environment
    deactivate
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
    fi

    ramp_static_dir="${APP_ROOT}/django/static/ramp"

    # install fgp to ramp static
    printf "${SPACER}${Cyan}${INDENT}Download the FGPV distro${NC}${SPACER}"
    cd ${ramp_static_dir}
    wget https://github.com/fgpv-vpgf/fgpv-vpgf/releases/download/v${FGP_VERSION}/fgpv-${FGP_VERSION}.zip
    unzip fgpv-${FGP_VERSION}.zip
    rm -f fgpv-${FGP_VERSION}.zip
    cd ${APP_ROOT}

    # download the wet GCWeb distro into ramp viewer
    printf "${SPACER}${Cyan}${INDENT}Download the GCWeb distro${NC}${SPACER}"
    mkdir -p ${ramp_static_dir}/GCWeb
    cd ${ramp_static_dir}/GCWeb
    wget https://github.com/wet-boew/GCWeb/archive/v${GCWEB_DISTRO_VERSION}.zip
    unzip v${GCWEB_DISTRO_VERSION}.zip
    rm -f v${GCWEB_DISTRO_VERSION}.zip
    cd ${APP_ROOT}

    # download wet-boew distro into ramp viewer
    printf "${SPACER}${Cyan}${INDENT}Download the wet-boew distro${NC}${SPACER}"
    mkdir -p ${ramp_static_dir}/wet-boew
    cd ${ramp_static_dir}/wet-boew
    wget https://github.com/wet-boew/wet-boew/releases/download/v${WET_DISTRO_VERSION}/wet-boew-dist-${WET_DISTRO_VERSION}.zip
    unzip wet-boew-dist-${WET_DISTRO_VERSION}.zip
    rm -f wet-boew-dist-${WET_DISTRO_VERSION}.zip
    cd ${APP_ROOT}

    # pull the cenw-wscoe/sgdc-cdts repo
    printf "${SPACER}${Cyan}${INDENT}Pull the CDTS repo${NC}${SPACER}"
    mkdir -p ${APP_ROOT}/django/static/cdts/source
    cd ${APP_ROOT}/django/static/cdts/source
    rm -rf ./*
    rm -rf ./.??*
    git clone https://github.com/cenw-wscoe/sgdc-cdts.git .

    # unpack the cdts static release
    printf "${SPACER}${Cyan}${INDENT}Unpack the GCWeb Static release from the CDTS repo${NC}${SPACER}"
    unzip ${APP_ROOT}/django/static/cdts/source/GCWeb/static/Gcwebstatic-${CDTS_GCWEB_VERSION}.zip -d ${APP_ROOT}/django/static/cdts
    cd ${APP_ROOT}/django/static/cdts/static
    mv * ../
    cd ${APP_ROOT}/django/static/cdts
    rm -rf ${APP_ROOT}/django/static/cdts/static
    cd ${APP_ROOT}

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
