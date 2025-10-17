#!/bin/bash

#
# Destroy and pull and install fast-forwarded repositories
#
if [[ $installRepos_AIA == "true" ]]; then

    mkdir -p ${APP_ROOT}/aia

    # nuke the entire folder
    printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing AIA install${NC}${SPACER}"
    # destroy all files
    cd ${APP_ROOT}/aia
    rm -rf ./*
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all files in aia: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Remove all files in aia: FAIL${NC}${EOL}"
    fi
    cd ${APP_ROOT}/aia
    rm -rf ./.??*
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove all hidden files in aia: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Remove all hidden files in aia: FAIL${NC}${EOL}"
    fi

    # make src folder
    mkdir -p ${APP_ROOT}/aia/src

    # set ownership
    chown vuejs:vuejs -R ${APP_ROOT}/aia
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set aia ownership to vuejs:vuejs: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set aia ownership to vuejs:vuejs: FAIL${NC}${EOL}"
    fi

    # install ckan core into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}AIA Core repository${HAIR}${Cyan} from https://github.com/canada-ca/aia-eia-js.git and installing into Node environment${NC}${SPACER}"
    git clone https://github.com/canada-ca/aia-eia-js.git ${APP_ROOT}/aia/src

    cd ${APP_ROOT}/aia/src
    npm install

    #
    # copy local ckan config files
    #
    cd ${APP_ROOT}

    # TODO: copy any configs needed...
    # copy local ckan config files
    # cp ${APP_ROOT}/_config/ckan/registry.ini ${APP_ROOT}/ckan/registry.ini
    # printf "${SPACER}${Cyan}${INDENT}Copying local registry config file to into Python environment${NC}${SPACER}"
    # if [[ $? -eq 0 ]]; then
    #     printf "${Green}${INDENT}${INDENT}Copy registry.ini to ckan/registry.ini: OK${NC}${EOL}"
    # else
    #     printf "${Red}${INDENT}${INDENT}Copy registry.ini to ckan/registry.ini: FAIL${NC}${EOL}"
    # fi
    # cp ${APP_ROOT}/_config/ckan/portal.ini ${APP_ROOT}/ckan/portal.ini
    # printf "${SPACER}${Cyan}${INDENT}Copying local portal config file to into Python environment${NC}${SPACER}"
    # if [[ $? -eq 0 ]]; then
    #     printf "${Green}${INDENT}${INDENT}Copy portal.ini to ckan/portal.ini: OK${NC}${EOL}"
    # else
    #     printf "${Red}${INDENT}${INDENT}Copy portal.ini to ckan/portal.ini: FAIL${NC}${EOL}"
    # fi


    # copy local ckan test config files=
    # cp ${APP_ROOT}/_config/ckan/test.ini ${APP_ROOT}/ckan/test.ini
    # printf "${SPACER}${Cyan}${INDENT}Copying local test config file to into Python environment${NC}${SPACER}"
    # if [[ $? -eq 0 ]]; then
    #     printf "${Green}${INDENT}${INDENT}Copy test.ini to ckan/test.ini: OK${NC}${EOL}"
    # else
    #     printf "${Red}${INDENT}${INDENT}Copy test.ini to ckan/test.ini: FAIL${NC}${EOL}"
    # fi

    cd ${APP_ROOT}/aia
    # END
    # copy local ckan config files
    # END

    # set ownership
    chown vuejs:vuejs -R ${APP_ROOT}/aia
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set aia ownership to vuejs:vuejs: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set aia ownership to vuejs:vuejs: FAIL${NC}${EOL}"
    fi

fi
# END
# Destroy and pull and install fast-forwarded repositories
# END
