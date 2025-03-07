# -- CKAN 2.9 --

import os
activate_this = '/srv/app/ckan/bin/activate_this.py'
exec(open(activate_this).read(), {'__file__': activate_this})

config_filepath = os.path.join('/srv/app/ckan/portal.ini')
test_config_filepath = os.path.join('/srv/app/ckan/test.ini')

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
