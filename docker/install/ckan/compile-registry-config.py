# -- CKAN 2.8 --

import os
activate_this = os.path.join('/srv/app/ckan/registry/bin/activate_this.py')
execfile(activate_this, dict(__file__=activate_this))

config_filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'registry.ini')
test_config_filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'test.ini')

import configparser

config = configparser.ConfigParser()
config.read(config_filepath)
config['DEFAULT']['project_id'] = os.getenv('PROJECT_ID')
with open(config_filepath,'w') as file:
    config.write(file)

testConfig = configparser.ConfigParser()
testConfig.read(test_config_filepath)
testConfig['DEFAULT']['project_id'] = os.getenv('PROJECT_ID')
with open(test_config_filepath,'w') as file:
    testConfig.write(file)