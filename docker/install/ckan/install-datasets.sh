#!/bin/bash

#
# Import Datasets
#
if [[ $installDatasets_CKAN == "true" ]]; then

    # remove old datasets file
    printf "${SPACER}${Cyan}${INDENT}Remove old Datasets file${NC}${SPACER}"
    rm -rf ${APP_ROOT}/backup/od-do-canada.jsonl.gz

    # activate python environment
    . ${APP_ROOT}/ckan/bin/activate
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Activate Python environment: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Activate Python environment: FAIL${NC}${EOL}"
    fi

    # download new datasets
    printf "${SPACER}${Cyan}${INDENT}Download new Datasets file${NC}${SPACER}"
    curl --output ${APP_ROOT}/backup/od-do-canada.jsonl.gz https://open.canada.ca/static/od-do-canada.jsonl.gz
    chown ckan:ckan ${APP_ROOT}/backup/od-do-canada.jsonl.gz

    # import the datasets
    printf "${SPACER}${Cyan}${INDENT}Import Datasets${NC}${SPACER}"
    ckanapi load datasets -I ${APP_ROOT}/backup/od-do-canada.jsonl.gz -z -p 16 -c ${APP_ROOT}/ckan/registry.ini -l ${APP_ROOT}/backup/registry__dataset_import__$(date +%s).log
    chown ckan:ckan ${APP_ROOT}/backup/registry__dataset_import__*.log

    # decativate python environment
    deactivate
    if [[ $? -eq 0 ]]; then
        printf "${Green}${INDENT}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
    else
        printf "${Red}${INDENT}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
    fi

fi
# END
# Import Datasets
# END
