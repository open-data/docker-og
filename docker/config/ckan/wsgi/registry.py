# -- coding: utf-8 --

# -- CKAN 2.9 --

import os
activate_this = os.path.join('/srv/app/ckan/registry/bin/activate_this.py')
execfile(activate_this, dict(__file__=activate_this))
from ckan.config.middleware import make_app
from ckan.cli import CKANConfigLoader
from logging.config import fileConfig as loggingFileConfig

config_filepath = os.path.join('/srv/app/ckan/registry/registry.ini')
test_config_filepath = os.path.join('/srv/app/ckan/registry/test.ini')

abspath = os.path.join(os.path.dirname(os.path.abspath(__file__)))

loggingFileConfig(config_filepath)

import configparser

config = configparser.ConfigParser()
config.read(config_filepath)
config['DEFAULT']['project_id'] = os.getenv('PROJECT_ID')
config['DEFAULT']['project_port'] = os.getenv('PROJECT_PORT')
with open(config_filepath,'w') as file:
    config.write(file)

testConfig = configparser.ConfigParser()
testConfig.read(test_config_filepath)
testConfig['DEFAULT']['project_id'] = os.getenv('PROJECT_ID')
config['DEFAULT']['project_port'] = os.getenv('PROJECT_PORT')
with open(test_config_filepath,'w') as file:
    testConfig.write(file)

config = CKANConfigLoader(config_filepath).get_config()

from werkzeug.debug import DebuggedApplication
application = DebuggedApplication(loadapp('config:%s' % config_filepath), evalex=True)
