#!/bin/bash

#
# Create a super user account
# cannot fully automate this due to Django bug
# with --no-input does not make a password.
#
if [[ $installUser_Django == "true" ]]; then

  printf "${Cyan}${INDENT}Creating a super user. Prompting for user input...${NC}${EOL}"

  # activate python environment
  . ${APP_ROOT}/django/bin/activate
  if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}Activate Python environment: OK${NC}${EOL}"
  else
      printf "${Red}${INDENT}Activate Python environment: FAIL${NC}${EOL}"
  fi

  # create a super user
  cd ${APP_ROOT}/django/src/oc-search
  python manage.py createsuperuser
  cd ${APP_ROOT}

  # decativate python environment
  deactivate
  if [[ $? -eq 0 ]]; then
      printf "${Green}${INDENT}Deactivate Python environment: OK${NC}${EOL}"
  else
      printf "${Red}${INDENT}Deactivate Python environment: FAIL${NC}${EOL}"
  fi

fi
# END
# Create a super user account
# END
