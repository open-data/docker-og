#!/bin/bash

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
    python3 -m venv ${APP_ROOT}/ckan/${CKAN_ROLE}
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

    # install ckan core into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Core repository${HAIR}${Cyan} from https://github.com:open-data/ckan.git@canada-v2.10 and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckan.git@canada-v2.10#egg=ckan' -r 'https://raw.githubusercontent.com/open-data/ckan/canada-v2.10/requirements.txt' -r 'https://raw.githubusercontent.com/open-data/ckan/canada-v2.10/dev-requirements.txt'

    # install ckanapi into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN API repository${HAIR}${Cyan} from https://github.com:ckan/ckanapi.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/ckan/ckanapi.git#egg=ckanapi' -r 'https://raw.githubusercontent.com/ckan/ckanapi/master/requirements.txt'

    # install ckan canada into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Canada repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-canada.git@canada-v2.10 and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-canada.git@canada-v2.10#egg=ckanext-canada' -r 'https://raw.githubusercontent.com/open-data/ckanext-canada/canada-v2.10/requirements.txt'

    # install ckan cloud storage into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Cloud Storage repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-cloudstorage.git@canada-v2.10 and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-cloudstorage.git@canada-v2.10#egg=ckanext-cloudstorage' -r 'https://raw.githubusercontent.com/open-data/ckanext-cloudstorage/canada-v2.10/requirements.txt'

    # install ckan dcat into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN DCat repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-dcat.git@canada-v2.10 and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-dcat.git@canada-v2.10#egg=ckanext-dcat' -r 'https://raw.githubusercontent.com/open-data/ckanext-dcat/canada-v2.10/requirements.txt'

    # install ckan fluent into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Fluent repository${HAIR}${Cyan} from https://github.com:ckan/ckanext-fluent.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/ckan/ckanext-fluent.git#egg=ckanext-fluent' -r 'https://raw.githubusercontent.com/ckan/ckanext-fluent/master/requirements.txt'

    # install ckan recombinant into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Recombinant repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-recombinant.git@master and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-recombinant.git@master#egg=ckanext-recombinant' -r 'https://raw.githubusercontent.com/open-data/ckanext-recombinant/master/requirements.txt'

    # install ckan scheming into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Scheming repository${HAIR}${Cyan} from https://github.com:ckan/ckanext-scheming.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/ckan/ckanext-scheming.git#egg=ckanext-scheming'

    # install ckan security into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Security repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-security@canada-v2.10 and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-security.git@canada-v2.10#egg=ckanext-security' -r 'https://raw.githubusercontent.com/open-data/ckanext-security/canada-v2.10/requirements.txt'

    # install ckan validation into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Validation repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-validation.git@canada-v2.10 and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-validation.git@canada-v2.10#egg=ckanext-validation' -r 'https://raw.githubusercontent.com/open-data/ckanext-validation/canada-v2.10/requirements.txt' -r 'https://raw.githubusercontent.com/open-data/ckanext-validation/canada-v2.10/dev-requirements.txt'

    # install ckan xloader into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Xloader repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-xloader.git@canada-v2.10  and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-xloader.git@canada-v2.10#egg=ckanext-xloader' -r 'https://raw.githubusercontent.com/open-data/ckanext-xloader/canada-v2.10/requirements.txt' -r 'https://raw.githubusercontent.com/open-data/ckanext-xloader/master/dev-requirements.txt'

    # install frictionless into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}Frictionless repository${HAIR}${Cyan} from https://github.com:open-data/frictionless-py.git@canada-v2.10 and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/frictionless-py.git@canada-v2.10#egg=frictionless'

    # install ckan gc notify into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN GC Notify repository${HAIR}${Cyan} from https://github.com:open-data/ckanext-gcnotify.git@master and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-gcnotify.git@master#egg=ckanext-gcnotify' -r 'https://raw.githubusercontent.com/open-data/ckanext-gcnotify/master/requirements.txt'

    # install Open API View into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Open API View repository${HAIR}${Cyan} from https://github.com/open-data/ckanext-openapiview.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-openapiview.git#egg=ckanext-openapiview'

    # install Power BI View into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Power BI View repository${HAIR}${Cyan} from https://github.com/open-data/ckanext-power-bi.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/ckanext-power-bi.git#egg=ckanext-power-bi' -r https://raw.githubusercontent.com/open-data/ckanext-power-bi/main/requirements.txt

    # install Excel Forms into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN Excel Forms repository${HAIR}${Cyan} from https://github.com/ckan/ckanext-excelforms.git@cmain and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/ckan/ckanext-excelforms.git@main#egg=ckanext-excelforms' -r 'https://raw.githubusercontent.com/ckan/ckanext-excelforms/main/requirements.txt'

    # install DataStore Audit into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}CKAN DS Audit repository${HAIR}${Cyan} from https://github.com/ckan/ckanext-dsaudit.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/ckan/ckanext-dsaudit.git#egg=ckanext-dsaudit'

    # install Frictionless fork into the python environment
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}Frictionless fork repository${HAIR}${Cyan} from https://github.com/open-data/frictionless-py.git and installing into Python environment${NC}${SPACER}"
    pip install -e 'git+https://github.com/open-data/frictionless-py.git@canada-v2.10#egg=frictionless-py'

    #
    # copy local ckan config files
    #
    cd ${APP_ROOT}

    # copy local ckan config file
    cp ${APP_ROOT}/_config/ckan/${CKAN_ROLE}.ini ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini
    printf "${SPACER}${Cyan}${INDENT}Copying local ${CKAN_ROLE} config file to into Python environment${NC}${SPACER}"
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ${CKAN_ROLE}.ini to ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Copy ${CKAN_ROLE}.ini to ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini: FAIL${NC}${EOL}"
    fi


    # copy local ckan test config file
    cp ${APP_ROOT}/_config/ckan/${CKAN_ROLE}-test.ini ${APP_ROOT}/ckan/${CKAN_ROLE}/test.ini
    printf "${SPACER}${Cyan}${INDENT}Copying local ${CKAN_ROLE} test config file to into Python environment${NC}${SPACER}"
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ${CKAN_ROLE}-test.ini to ckan/${CKAN_ROLE}/test.ini: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Copy ${CKAN_ROLE}-test.ini to ckan/${CKAN_ROLE}/test.ini: FAIL${NC}${EOL}"
    fi

    # compile ckan config files
    printf "${SPACER}${Cyan}${INDENT}Copying activation script into ${CKAN_ROLE} venv${NC}${SPACER}"
    cp ${APP_ROOT}/docker/install/ckan/activate_this.py ${APP_ROOT}/ckan/${CKAN_ROLE}/bin/activate_this.py
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy ${CKAN_ROLE} activation script: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Copy ${CKAN_ROLE} activation script: FAIL${NC}${EOL}"
    fi
    chown ckan:ckan ${APP_ROOT}/ckan/${CKAN_ROLE}/bin/activate_this.py
    printf "${SPACER}${Cyan}${INDENT}Compiling local ${CKAN_ROLE} config files${NC}${SPACER}"
    python3 ${PWD}/docker/install/ckan/compile-${CKAN_ROLE}-config.py
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Compile ${CKAN_ROLE} ini files: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Compile ${CKAN_ROLE} ini files: FAIL${NC}${EOL}"
    fi

    cd ${APP_ROOT}/ckan/${CKAN_ROLE}
    # END
    # copy local ckan config files
    # END

    # copy who config file
    cp ${APP_ROOT}/_config/ckan/who.ini ${APP_ROOT}/ckan/${CKAN_ROLE}/who.ini
    printf "${SPACER}${Cyan}${INDENT}Copying CKAN who config file to into root Python environment${NC}${SPACER}"
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copy _config/who.ini to ckan/${CKAN_ROLE}/who.ini: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Copy _config/who.ini to ckan/${CKAN_ROLE}/who.ini: FAIL${NC}${EOL}"
    fi

    # create i18n directory
    mkdir -p /srv/app/ckan/${CKAN_ROLE}/src/ckanext-canada/build
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create /srv/app/ckan/${CKAN_ROLE}/src/ckanext-canada/build: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Create /srv/app/ckan/${CKAN_ROLE}/src/ckanext-canada/build: FAIL (directory may already exist)${NC}${EOL}"
    fi

    # generate ckan command
    cd /srv/app/ckan/${CKAN_ROLE}/src/ckan
    python3 setup.py develop

    # generate translation files
    cd /srv/app/ckan/${CKAN_ROLE}/src/ckanext-canada
    python3 setup.py compile_catalog

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
