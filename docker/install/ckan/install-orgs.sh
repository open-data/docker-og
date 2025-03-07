#!/bin/bash

#
# Import Organizations
#
if [[ $installOrgs_CKAN == "true" ]]; then

    # remove old orgs file
    printf "${SPACER}${Cyan}${INDENT}Remove old orgs.jsonl file${NC}${SPACER}"
    rm -rf ${APP_ROOT}/backup/orgs.jsonl

    # dump new orgs
    printf "${SPACER}${Cyan}${INDENT}Dump latest Organizations into orgs.jsonl file${NC}${SPACER}"
    ckanapi dump organizations --all -r https://open.canada.ca/data -O ${APP_ROOT}/backup/orgs.jsonl
    chown ckan:ckan ${APP_ROOT}/backup/orgs.jsonl

    # import the orgs
    printf "${SPACER}${Cyan}${INDENT}Import Organizations${NC}${SPACER}"
    ckanapi load organizations -I ${APP_ROOT}/backup/orgs.jsonl -c ${APP_ROOT}/ckan/registry.ini

fi
# END
# Import Organizations
# END
