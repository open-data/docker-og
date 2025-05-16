#!/bin/bash

#
# Import Organizations
#
if [[ $installOrgs_CKAN == "true" ]]; then

    # remove old orgs file
    printf "${SPACER}${Cyan}${INDENT}Remove old orgs.jsonl file${NC}${SPACER}"
    rm -rf ${APP_ROOT}/backup/orgs.jsonl

    # activate python environment
    . ${APP_ROOT}/ckan/bin/activate
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Activate Python environment: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Activate Python environment: FAIL${NC}${EOL}"
    fi

    # dump new orgs
    printf "${SPACER}${Cyan}${INDENT}Dump latest Organizations into orgs.jsonl file${NC}${SPACER}"
    ckanapi dump organizations --all -r https://open.canada.ca/data -O ${APP_ROOT}/backup/orgs.jsonl
    chown ckan:ckan ${APP_ROOT}/backup/orgs.jsonl

    # import the orgs
    printf "${SPACER}${Cyan}${INDENT}Import Organizations${NC}${SPACER}"
    ckanapi load organizations -I ${APP_ROOT}/backup/orgs.jsonl -c ${APP_ROOT}/ckan/registry.ini

    # decativate python environment
    deactivate
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
    fi

fi
# END
# Import Organizations
# END
