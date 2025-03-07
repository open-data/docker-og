#!/bin/bash

#
# Variables
#

# text
Cyan='\033[0;36m'
Yellow='\033[1;33m'
Red='\033[0;31m'
Orange='\033[0;33m'
Green='\033[0;32m'
NC='\033[0;0m'
EOL='\n'
SPACER='\n\n'
INDENT='    '
BOLD='\033[1m'
HAIR='\033[0m'

do_install='false'

PWD=$(pwd);

if [[ ! -d "${PWD}/src" ]]; then

	printf "${EOL}${Red}${INDENT}Directory ./src does not exist in the current working directory. Exiting...${NC}${SPACER}";
	exit 1;

fi;

read -r -p $'\n\033[0;33m    Are you sure you want to install all sources from ./src into the\033[1m currently activated python virtual environment\033[0m\033[0;33m? [y/N]:\033[0;0m    ' response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then

	do_install='true'

else

	do_install='false'

fi;

if [[ $do_install == "true" ]]; then

	printf "${EOL}${Cyan}${INDENT}Installing all source directories from ${PWD}/src${NC}${EOL}";

	for dir in $PWD/src/*; do

		if [[ -d "$dir" ]]; then

			printf "${EOL}${Cyan}${INDENT}Installing ${dir##*/}${NC}${EOL}";

			cd $dir;

			if [[ -f "./requirement-setuptools.txt" ]]; then

				pip install -r requirement-setuptools.txt;

			fi;

			if [[ -f "./requirements.txt" ]]; then

				pip install -r requirements.txt;

			fi;

      if [[ -f "./dev-requirements.txt" ]]; then

				pip install -r dev-requirements.txt;

			fi;

      if [[ -f "./requirements-test.txt" ]]; then

				pip install -r requirements-test.txt;

			fi;

			pip install -e .

			if [[ -f "./setup.py" ]]; then

				python setup.py develop;

			fi;

			printf "${EOL}${Green}${INDENT}Installed ${dir##*/}${NC}${EOL}";

			cd $PWD;

		fi;

	done;

	printf "${EOL}${Cyan}${INDENT}Installing UWSGI${NC}${EOL}";

	pip install uwsgi;

	printf "${EOL}${Green}${INDENT}Installed UWSGI${NC}${EOL}";

else

	printf "${EOL}${Cyan}${INDENT}Script cancelled. Exiting...${NC}${SPACER}";

fi;
