# -- coding: utf-8 --

# -- CKAN 2.9 --

import os
activate_this = '/srv/app/ckan/bin/activate_this.py'
exec(open(activate_this).read(), {'__file__': activate_this})
from ckan.config.middleware import make_app
from ckan.cli import CKANConfigLoader
from logging.config import fileConfig as loggingFileConfig

config_filepath = os.path.join('/srv/app/ckan/portal.ini')

abspath = os.path.join(os.path.dirname(os.path.abspath(__file__)))

loggingFileConfig(config_filepath)

import configparser

config = configparser.ConfigParser()
config.read(config_filepath)
config['DEFAULT']['project_id'] = str(os.getenv('PROJECT_ID'))
config['DEFAULT']['project_port'] = str(os.getenv('PROJECT_PORT'))
with open(config_filepath,'w') as file:
    config.write(file)

config = CKANConfigLoader(config_filepath).get_config()

from werkzeug.debug import DebuggedApplication
application = DebuggedApplication(make_app(config), evalex=True)
