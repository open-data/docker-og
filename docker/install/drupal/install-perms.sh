#!/bin/bash

#
# Set file and directory ownership and permissions
#
if [[ $installFilePermissions_Drupal == "true" ]]; then

    printf "${SPACER}${Cyan}${INDENT}Download Drupal default settings file${NC}${SPACER}"
    cd ${APP_ROOT}/drupal/html/sites
    # remove old settings file
    rm -rf ${APP_ROOT}/drupal/html/sites/default.settings.php
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Removed sites/default.settings.php: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Removed sites/default.settings.php: FAIL (file may not exist)${NC}${EOL}"
    fi
    wget https://raw.githubusercontent.com/drupal/drupal/8.8.x/sites/default/default.settings.php
    mkdir -p ${APP_ROOT}/drupal/html/sites/default
    cd ${APP_ROOT}/drupal/html/sites/default
    # remove old settings file
    rm -rf ${APP_ROOT}/drupal/html/sites/default/default.settings.php
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Removed sites/default/default.settings.php: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Removed sites/default/default.settings.php: FAIL (file may not exist)${NC}${EOL}"
    fi
    wget https://raw.githubusercontent.com/drupal/drupal/8.8.x/sites/default/default.settings.php

    printf "${SPACER}${Cyan}${INDENT}Copy Drupal settings file${NC}${SPACER}"
    # copy docker config settings.php to drupal directory
    cp ${APP_ROOT}/_config/drupal/settings.php ${APP_ROOT}/drupal/html/sites/settings.php
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied settings.php to sites/settings.php: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Copied settings.php to sites/settings.php: FAIL${NC}${EOL}"
    fi
    # copy docker config settings.php to drupal directory
    cp ${APP_ROOT}/_config/drupal/settings.php ${APP_ROOT}/drupal/html/sites/default/settings.php
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied settings.php to sites/default/settings.php: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Copied settings.php to sites/default/settings.php: FAIL${NC}${EOL}"
    fi

    printf "${SPACER}${Cyan}${INDENT}Copy Drupal services file${NC}${SPACER}"
    # copy docker config development.services.yml to drupal directory
    cp ${APP_ROOT}/_config/drupal/services.yml ${APP_ROOT}/drupal/html/sites/development.services.yml
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied services.yml to sites/development.services.yml: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Copied services.yml to sites/development.services.yml: FAIL${NC}${EOL}"
    fi
    # copy docker config development.services.yml to drupal directory
    cp ${APP_ROOT}/_config/drupal/services.yml ${APP_ROOT}/drupal/html/sites/default/development.services.yml
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Copied services.yml to sites/default/development.services.yml: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Copied services.yml to sites/default/development.services.yml: FAIL${NC}${EOL}"
    fi

    printf "${SPACER}${Cyan}${INDENT}Set Drupal settings file permissions${NC}${SPACER}"
    # set file permissions for settings file
    chmod 644 ${APP_ROOT}/drupal/html/sites/settings.php
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/settings.php perms to 644: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set sites/settings.php perms to 644: FAIL${NC}${EOL}"
    fi
    # set file permissions for default settings file
    chmod 644 ${APP_ROOT}/drupal/html/sites/default.settings.php
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default.settings.php perms to 644: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set sites/default.settings.php to 644: FAIL${NC}${EOL}"
    fi
    # set file permissions for settings file
    chmod 644 ${APP_ROOT}/drupal/html/sites/default/settings.php
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/settings.php perms to 644: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set sites/default/settings.php perms to 644: FAIL${NC}${EOL}"
    fi
    # set file permissions for default settings file
    chmod 644 ${APP_ROOT}/drupal/html/sites/default/default.settings.php
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/default.settings.php perms to 644: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set sites/default/default.settings.php perms to 644: FAIL${NC}${EOL}"
    fi

    printf "${SPACER}${Cyan}${INDENT}Create config sync directory${NC}${SPACER}"
    # create drupal config sync directory
    mkdir -p ${APP_ROOT}/drupal/html/sites/default/sync
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create sites/default/sync: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Create sites/default/sync: FAIL (directory may already exist)${NC}${EOL}"
    fi

    printf "${SPACER}${Cyan}${INDENT}Create private files directory${NC}${SPACER}"
    #create private files directory
    mkdir -p ${APP_ROOT}/drupal/html/sites/default/private-files
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Create sites/default/private-files: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Create sites/default/private-files: FAIL (directory may already exist)${NC}${EOL}"
    fi
    # add htaccess file
    echo "Deny from all" > ${APP_ROOT}/drupal/html/sites/default/private-files/.htaccess
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Added Deny from all to private files directory: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Added Deny from all to private files directory: FAIL${NC}${EOL}"
    fi
    # set file permissions of new htaccess file
    chmod 644 ${APP_ROOT}/drupal/html/sites/default/private-files/.htaccess
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set private directory htaccess perms to 644: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set private directory htaccess perms to 644: FAIL${NC}${EOL}"
    fi

    printf "${SPACER}${Cyan}${INDENT}Set public files permissions${NC}${SPACER}"
    # set file permissions of public files directory
    chmod 755 ${APP_ROOT}/drupal/html/sites/default/files
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/files perms to 755: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set sites/default/files perms to 755: FAIL${NC}${EOL}"
    fi

    # set file permissions of public files inner directories
    find ${APP_ROOT}/drupal/html/sites/default/files -type d -exec chmod 755 {} \;
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/files inner directory perms to 755: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set sites/default/files inner directory perms to 755: FAIL${NC}${EOL}"
    fi

    # set file permissions of public files inner files
    find ${APP_ROOT}/drupal/html/sites/default/files -type f -exec chmod 644 {} \;
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set sites/default/files inner files perms to 644: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set sites/default/files inner files perms to 644: FAIL${NC}${EOL}"
    fi

    printf "${SPACER}${Cyan}${INDENT}Set Drupal file ownership${NC}${SPACER}"
    # set file system ownership for the drupal directory
    chown www-data:www-data -R ${APP_ROOT}/drupal
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Set file system ownership to www-data: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Set file system ownership to www-data: FAIL${NC}${EOL}"
    fi

fi
# END
# Set file and directory ownership and permissions
# END