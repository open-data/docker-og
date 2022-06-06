#!/bin/bash

#
# Pull Drupal Core repo, Drupal profile repo, and Drupal theme repo
#
if [[ $installRepos_Drupal == "true" ]]; then

    mkdir -p ${APP_ROOT}/drupal
    cd ${APP_ROOT}/drupal

    # nuke the entire folder
    printf "${SPACER}${Cyan}${INDENT}Pre-nuke the existing Drupal install${NC}${SPACER}"
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

    # pull the core site
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}OG repository${HAIR}${Cyan} from https://github.com/open-data/opengov.git${NC}${SPACER}"
    git config --global init.defaultBranch master
    # destroy the local git repo config
    rm -rf .git
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove .git: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Remove .git: FAIL (local repo may not exist)${NC}${EOL}"
    fi
    rm -rf ./*
    rm -rf ./.??*
    git clone https://github.com/open-data/opengov.git .

    # pull the profile
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}Profile repository${HAIR}${Cyan} from https://github.com/open-data/og.git${NC}${SPACER}"
    # destroy the local git repo config
    cd ${APP_ROOT}/drupal/html/profiles/og
    rm -rf .git
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove profiles/og/.git: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Remove profiles/og/.git: FAIL (local repo may not exist)${NC}${EOL}"
    fi
    rm -rf ./*
    rm -rf ./.??*
    git clone https://github.com/open-data/og.git .

    # pull the theme
    printf "${SPACER}${Cyan}${INDENT}Pulling ${BOLD}Theme repository${HAIR}${Cyan} from https://github.com/open-data/gcweb_bootstrap.git${NC}${SPACER}"
    cd ${APP_ROOT}/drupal/html/themes/custom/gcweb
    # destroy the local git repo config
    rm -rf .git
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Remove themes/custom/gcweb/.git: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Remove themes/custom/gcweb/.git: FAIL (local repo may not exist)${NC}${EOL}"
    fi
    rm -rf ./*
    rm -rf ./.??*
    git clone https://github.com/open-data/gcweb_bootstrap.git .

fi
# END
# Pull Drupal Core repo, Drupal profile repo, and Drupal theme repo
# END