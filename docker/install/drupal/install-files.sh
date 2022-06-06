#!/bin/bash

#
# Install Local Files
#
if [[ $installFiles_Drupal == "true" ]]; then

    if [[ -f "${APP_ROOT}/backup/drupal_files.tgz" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Local backup file exists, using ${BOLD}${APP_ROOT}/backup/drupal_files.tgz${PROJECT_ID}${HAIR}${NC}${SPACER}"

        printf "${SPACER}${Cyan}${INDENT}Extract public files from backup${NC}${SPACER}"
        # create default sites directory
        mkdir -p ${APP_ROOT}/drupal/html/sites/default
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Create sites/default: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Create sites/default: FAIL (directory may already exist)${NC}${EOL}"
        fi
        # remove default files directory
        rm -rf ${APP_ROOT}/drupal/html/sites/default/files
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Removed sites/default/files: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Removed sites/default/files: FAIL (directory may not exist)${NC}${EOL}"
        fi
        cd ${APP_ROOT}/drupal/html/sites/default
        tar zxvf ${APP_ROOT}/backup/drupal_files.tgz        

    elif  [[ -f "/opt/tbs/docker/backup/drupal_files.tgz" ]]; then

        printf "${SPACER}${Cyan}${INDENT}Global backup file exists, using ${BOLD}/opt/tbs/docker/backup/drupal_files.tgz${PROJECT_ID}${HAIR}${NC}${SPACER}"

        printf "${SPACER}${Cyan}${INDENT}Extract public files from backup${NC}${SPACER}"
        # create default sites directory
        mkdir -p ${APP_ROOT}/drupal/html/sites/default
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Create sites/default: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Create sites/default: FAIL (directory may already exist)${NC}${EOL}"
        fi
        # remove default files directory
        rm -rf ${APP_ROOT}/drupal/html/sites/default/files
        if [[ $? -eq 0 ]]; then
            printf "${Green}${INDENT}${INDENT}Removed sites/default/files: OK${NC}${EOL}"
        else
            printf "${Red}${INDENT}${INDENT}Removed sites/default/files: FAIL (directory may not exist)${NC}${EOL}"
        fi
        cd ${APP_ROOT}/drupal/html/sites/default
        tar zxvf /opt/tbs/docker/backup/drupal_files.tgz

    else

        printf "${SPACER}${Orange}${INDENT}Skipping ${BOLD}drupal files${HAIR}${Orange} import, no local or global backup found.${NC}${SPACER}"

    fi

fi
# END
# Install Local Files
# END