#!bin/python
"""
WSGI config for oc_search project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/3.0/howto/deployment/wsgi/
"""

import os
import sys

activate_this = os.path.join('/srv/app/django/bin/activate_this.py')
exec(compile(open(activate_this, "rb").read(), 'activate_this.py', 'exec'))

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'oc_search.settings')

application = get_wsgi_application()
