# -- coding: utf-8 --

# -- CKAN 2.9 --

# import os
# from ckan.config.middleware import make_app
# from ckan.cli import CKANConfigLoader
# from logging.config import fileConfig as loggingFileConfig
# config_filepath = os.path.join(
#     os.path.dirname(os.path.abspath(__file__)), 'portal.ini')
# abspath = os.path.join(os.path.dirname(os.path.abspath(__file__)))
# loggingFileConfig(config_filepath)
# config = CKANConfigLoader(config_filepath).get_config()
# application = make_app(config)

# -- CKAN 2.8 --

import os
activate_this = os.path.join('/srv/app/ckan/portal/bin/activate_this.py')
execfile(activate_this, dict(__file__=activate_this))

from paste.deploy import loadapp
config_filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'portal.ini')
from paste.script.util.logging_config import fileConfig
fileConfig(config_filepath)
application = loadapp('config:%s' % config_filepath)