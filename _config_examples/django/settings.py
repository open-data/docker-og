"""
Django settings for oc_search project.

Generated by 'django-admin startproject' using Django 3.0.5.

For more information on this file, see
https://docs.djangoproject.com/en/3.0/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/3.0/ref/settings/
"""
import bleach.sanitizer
from django.utils.translation import gettext_lazy as _
import os

PROJECT_ID = os.getenv('PROJECT_ID')
PROJECT_PORT = os.getenv('PROJECT_PORT')

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/3.0/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'Replace_this_key_with_a_random_value!'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

ADMIN_ENABLED = True

DEFAULT_SEARCH_TYPE = 'data'

INTERNAL_IPS = ['127.0.0.1']

ALLOWED_HOSTS = ['127.0.0.1', 'localhost', 'search.open.local', "search.open.local:" + PROJECT_PORT]

# Application definition

INSTALLED_APPS = [
    'corsheaders',
    'jazzmin',
    'django_celery_beat',
    'django_celery_results',
    'django.contrib.admin',
    'django.contrib.admindocs',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.humanize',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'qurl_templatetag',
    'search',
    'smuggler',
    'ramp',
]

## Optional applications
# 'ramp',
# 'smuggler',

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'django.middleware.locale.LocaleMiddleware',
    'django.middleware.cache.UpdateCacheMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.cache.FetchFromCacheMiddleware',
    'oc_search.middleware.CanadaBilingualMiddleware'
]

CORS_ALLOW_ALL_ORIGINS = True
CSRF_TRUSTED_ORIGINS = ['https://*.open.canada.ca', 'https://*.ouvert.canada.ca', 'https://open.canada.ca', 'https://ouvert.canada.ca',
                        'http://*.open.local', 'http://open.local']

ROOT_URLCONF = 'oc_search.urls'

STATIC_ROOT = '/srv/app/django/static'

NLTK_DATADIR = '/srv/app/django/src/oc_search/nltk'

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/3.0/howto/static-files/

STATIC_URL = '/static/'

STATICFILES_DIRS = [
    ('cdts', '/srv/app/django/static/cdts'),
    ('search_snippets', '/srv/app/django/src/oc_search/search/templates/snippets'),
    ('ramp', '/srv/app/django/src/oc_search/ramp/viewer'),
]

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': ['/srv/app/django/static',
                 '/srv/app/django/src/oc_search/search/templates',
                 '/srv/app/django/src/oc_search/ramp/templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'oc_search.wsgi.application'


# Database
# https://docs.djangoproject.com/en/3.0/ref/settings/#databases

# The search application specifies a separate configuration for the main functions of the search application
# Future plugins are free to add other databaes if required but should not use the default database, or
# the default Database router defined in the db_router.py class, but should instead add their own router.

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'og_search_local',
        'HOST': 'postgres',
        'PORT': '5432',
        'USER': 'homestead',
        'PASSWORD': 'secret',
        'COMM_MAX_AGE': None,
    },
}

# Smuggler settings
SMUGGLER_FIXTURE_DIR = os.path.join(BASE_DIR, 'smuggler')
SMUGGLER_EXCLUDE_LIST = ['admin.logentry', 'auth.permission', 'auth.group', 'auth.user',
                         'contenttypes.contenttype',
                         'django_celery_results.chordcounter', 'django_celery_results.groupresult', 'django_celery_beat.taskresult']

#DATABASE_ROUTERS = ['search.db_router.SearchRouter']

# Password validation
# https://docs.djangoproject.com/en/3.0/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/3.0/topics/i18n/

LANGUAGE_CODE = 'en'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = True
USE_TZ = True
LANGUAGES = [
    ('en', _('English')),
    ('fr', _('French')),
]

LOCALE_PATHS = [
    os.path.join(BASE_DIR, 'locale'),
]

# File cache directory used by the export search results feature. If files are served by a web server like Nginx
# or Apache, set the FILE_CACHE_URL

EXPORT_FILE_CACHE_DIR = '/srv/app/django/static/cache'
EXPORT_FILE_CACHE_URL = "http://search.open.local:" + PROJECT_PORT + "/static/cache"

# Solr Search Configuration

SOLR_SERVER_URL = 'http://solr:8983/solr'

SOLR_COLLECTION = "SolrClient_unittest"

# Application URL

SEARCH_EN_HOSTNAME = ''
SEARCH_FR_HOSTNAME = ''
SEARCH_HOST_PATH = ''
SEARCH_LANG_USE_PATH = True

# Active CDTS Version

CDTS_VERSION = 'v4_0_32'

ANALYTICS_JS = ""

# Logging

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
}

MARKDOWN_FILTER_WHITELIST_TAGS = [
    'a',
    'b',
    'blockquote',
    'p',
    'code',
    'div',
    'em',
    'h1', 'h2', 'h3', 'h4',
    'i',
    'ul',
    'ol',
    'li',
    'br',
    'mark',
    'pre',
    'span',
    'strong',
    'table', 'thead', 'th', 'tr', 'tbody', 'td'
]
MARKDOWN_FILTER_EXTRAS = ["tables", "break-on-newline"]
# These are IN ADDITION to the attributes defined in leach.sanitizer.ALLOWED_ATTRIBUTES
MARKDOWN_FILTER_ALLOWED_ATTRIBUTES = {'span': ['title', 'class'], "a": ["href", "title", "rel", "target"], 'div': ['class']}

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.dummy.DummyCache',
    },
    'local': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'oc_search',
    }
}
# Object in the local cache expire after this many seconds. Not recommended to be less than 60 seconds.
CACHE_LOCAL_TIMEOUT = 60 * 5

# SESSION_FILE_PATH = os.path.join(BASE_DIR, 'session')
SESSION_EXPIRE_AT_BROWSER_CLOSE = True
SESSION_ENGINE = "redis_sessions.session"
SESSION_REDIS = {
    'host': 'redis',
    'port': 6379,
    'db': 0,
    'password': None,
    'unix_domain_socket_path': None,
    'prefix': 'oc_session',
    'socket_timeout': 2,
    'retry_on_timeout': True
}

ADOBE_ANALYTICS_URL = ''
GOOGLE_ANALYTICS_GTM_ID = ''
GOOGLE_ANALYTICS_PROPERTY_ID = ''
GOOGLE_ANALYTICS_GA4_ID = ''

IMPORT_EXPORT_USE_TRANSACTIONS = False

# RAMP Viewer Settings
OPEN_DATA_SOLR_SERVER_URL = "http://solr:8983/solr"
OPEN_DATA_CORE = "search_opendata"
OPEN_DATA_BASE_URL_EN = "http://open.local:" + PROJECT_PORT + "/data/en/dataset/"
OPEN_DATA_BASE_URL_FR = "http://open.local:" + PROJECT_PORT + "/data/fr/dataset/"
OPEN_DATA_EN_FGP_BASE = "http://search.open.local:" + PROJECT_PORT + "/openmap/"
OPEN_DATA_FR_FGP_BASE = "http://search.open.local:" + PROJECT_PORT + "/carteouverte/"
OPEN_DATA_HOST_EN = "http://open.local:" + PROJECT_PORT + ""
OPEN_DATA_HOST_FR = "http://open.local:" + PROJECT_PORT + ""

RAMP_SHOW_ALERT_INFO = False
RAMP_RANGE_SLIDER_CSS_URL = 'https://viewer-visualiseur.services.geo.ca/apps/RAMP/contributed-plugins/range-slider/range-slider.css'
RAMP_RANGE_SLIDER_JS_URL = 'https://viewer-visualiseur.services.geo.ca/apps/RAMP/contributed-plugins/range-slider/range-slider.js'
RAMP_CHART_CSS_URL = 'https://viewer-visualiseur.services.geo.ca/apps/RAMP/contributed-plugins/chart/chart.css'
RAMP_CHART_JS_URL = 'https://viewer-visualiseur.services.geo.ca/apps/RAMP/contributed-plugins/chart/chart.js'
RAMP_STYLE_CSS_URL = 'https://viewer-visualiseur.services.geo.ca/apps/RAMP/fgpv/fgpv-3.3.5/rv-styles.css'
RAMP_MAIN_JS_URL = 'https://viewer-visualiseur.services.geo.ca/apps/RAMP/fgpv/fgpv-3.3.5/rv-main.js'
RAMP_LEGACY_API_JS_URL = 'https://viewer-visualiseur.services.geo.ca/apps/RAMP/fgpv/fgpv-3.3.5/legacy-api.js'

CELERY_BROKER_URL = 'redis://:@redis:6379/2'
CELERY_RESULT_BACKEND = 'django-db'
CELERY_TIME_ZONE = TIME_ZONE
CELERY_RESULT_EXTENDED = True
CELERY_RESULT_EXPIRES = 60 * 60 * 24 * 7  # 1 week
# Max task time allowed in seconds
CELERYD_TIME_LIMIT = 20
# No. of Celery workers
CELERYD_CONCURRENCY = 2
# the task will report its status as ‘started’ when the task is executed by a worker.
CELERY_TASK_TRACK_STARTED = True

# Log file to hold exported search logs
SEARCH_LOGGING_ARCHIVE_FILE = os.path.join(BASE_DIR, 'data', 'search_logs.log')
SEARCH_LOGGING_ARCHIVE_AFTER_X_DAYS = 7

# Used by the Suggested Datasets Search

SD_COMMENTS_BASE_EN = "http://search.open.local:" + PROJECT_PORT + "/static/sd/"
SD_COMMENTS_BASE_FR = "http://search.open.local:" + PROJECT_PORT + "/static/sd/"
SD_VOTES_BASE_EN = "http://search.open.local:" + PROJECT_PORT + "/static/sd/"
SD_VOTES_BASE_FR = "http://search.open.local:" + PROJECT_PORT + "/static/sd/"

IMPORT_DATA_CSV_DEFAULT_DEBUG = True
IMPORT_DATA_CSV_SOLR_INDEX_GROUP_SIZE = 1000
IMPORT_DATA_CSV_BAD_DATA_DIR = '/srv/app/backup/pd_bad'
