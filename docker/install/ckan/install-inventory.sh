#!/bin/bash

#
# Import PD Inventory
#
if [[ $installInventory_CKAN == "true" ]]; then

    # remove old inventory file
    printf "${SPACER}${Cyan}${INDENT}Remove old inventory.csv file${NC}${SPACER}"
    rm -rf ${APP_ROOT}/backup/inventory.csv

    # download new inventory file
    printf "${SPACER}${Cyan}${INDENT}Download latest Inventory csv file${NC}${SPACER}"
    wget ${DATA_URI}/dataset/4ed351cf-95d8-4c10-97ac-6b3511f359b7/resource/d0df95a8-31a9-46c9-853b-6952819ec7b4/download/inventory.csv -O ${APP_ROOT}/backup/inventory.csv
    chown ckan:ckan ${APP_ROOT}/backup/inventory.csv

    # import the inventory
    printf "${SPACER}${Cyan}${INDENT}Import Inventory${NC}${SPACER}"
    ckan inventory rebuild --lenient -c ${APP_ROOT}/ckan/${CKAN_ROLE}/${CKAN_ROLE}.ini -f ${APP_ROOT}/backup/inventory.csv

fi
# END
# Import PD Inventory
# END
