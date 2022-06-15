#!/bin/bash

#
# Import Datasets
#
if [[ $installDatasets_CKAN == "true" ]]; then

    # remove old datasets file
    printf "${SPACER}${Cyan}${INDENT}Remove old Datasets file${NC}${SPACER}"
    rm -rf ${APP_ROOT}/backup/od-do-canada.jsonl.gz

    # download new datasets
    printf "${SPACER}${Cyan}${INDENT}Download new Datasets file${NC}${SPACER}"
    curl --output ${APP_ROOT}/backup/od-do-canada.jsonl.gz https://open.canada.ca/static/od-do-canada.jsonl.gz
    chown ckan:ckan ${APP_ROOT}/backup/od-do-canada.jsonl.gz

    # import the datasets
    printf "${SPACER}${Cyan}${INDENT}Import Datasets${NC}${SPACER}"
    ckanapi load datasets -I ${APP_ROOT}/backup/od-do-canada.jsonl.gz -z -p 16 -c ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini -l ${APP_ROOT}/backup/${CKAN_ROLE}__dataset_import__$(date +%s).log
    chown ckan:ckan ${APP_ROOT}/backup/${CKAN_ROLE}__dataset_import__*.log

fi
# END
# Import Datasets
# END