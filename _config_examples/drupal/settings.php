<?php

// @codingStandardsIgnoreFile
$dbName = 'og_drupal_local';
$databases['default']['default'] = [
    'driver'    => 'pgsql',
    'namespace' => 'Drupal\\Core\\Database\\Driver\\pgsql',
    'database'  => $dbName,
    'username'  => 'homestead',
    'password'  => 'secret',
    'host'      => 'postgres',
    'port'      => '5432',
];

$settings['hash_salt'] = 'this-is-a-totally-legitimate-hash';

$settings['config_sync_directory'] = '/var/www/html/drupal/config';

$settings['file_private_path'] = '/var/www/html/drupal/html/sites/default/private-files';

/**
 * Config override for Search API Solr
 */
$config['search_api.server.pd_core_ati']['backend_config']['connector_config']['scheme'] = 'http';
$config['search_api.server.pd_core_ati']['backend_config']['connector_config']['host'] = 'solr';
$config['search_api.server.pd_core_ati']['backend_config']['connector_config']['port'] = '8983';
$config['search_api.server.pd_core_ati']['backend_config']['connector_config']['core'] = 'drupal_ati';
$config['search_api.server.pd_core_ati']['backend_config']['connector_config']['path'] = '/';

$config['search_api.server.pd_core_contracts']['backend_config']['connector_config']['scheme'] = 'http';
$config['search_api.server.pd_core_contracts']['backend_config']['connector_config']['host'] = 'solr';
$config['search_api.server.pd_core_contracts']['backend_config']['connector_config']['port'] = '8983';
$config['search_api.server.pd_core_contracts']['backend_config']['connector_config']['core'] = 'drupal_contractsa';
$config['search_api.server.pd_core_contracts']['backend_config']['connector_config']['path'] = '/';

$config['search_api.server.drupal_content']['backend_config']['connector_config']['scheme'] = 'http';
$config['search_api.server.drupal_content']['backend_config']['connector_config']['host'] = 'solr';
$config['search_api.server.drupal_content']['backend_config']['connector_config']['port'] = '8983';
$config['search_api.server.drupal_content']['backend_config']['connector_config']['core'] = 'drupal_portal';
$config['search_api.server.drupal_content']['backend_config']['connector_config']['path'] = '/';

/**
 * Config for ckan public path
 */
$settings['ckan_public_path'] = '/var/www/html/backup';

/**
 * @file
 * Local development override configuration feature.
 *
 * To activate this feature, copy and rename it such that its path plus
 * filename is 'sites/default/settings.local.php'. Then, go to the bottom of
 * 'sites/default/settings.php' and uncomment the commented lines that mention
 * 'settings.local.php'.
 *
 * If you are using a site name in the path, such as 'sites/example.com', copy
 * this file to 'sites/example.com/settings.local.php', and uncomment the lines
 * at the bottom of 'sites/example.com/settings.php'.
 */

/**
 * Assertions.
 *
 * The Drupal project primarily uses runtime assertions to enforce the
 * expectations of the API by failing when incorrect calls are made by code
 * under development.
 *
 * @see http://php.net/assert
 * @see https://www.drupal.org/node/2492225
 *
 * If you are using PHP 7.0 it is strongly recommended that you set
 * zend.assertions=1 in the PHP.ini file (It cannot be changed from .htaccess
 * or runtime) on development machines and to 0 in production.
 *
 * @see https://wiki.php.net/rfc/expectations
 */
assert_options(ASSERT_ACTIVE, TRUE);
\Drupal\Component\Assertion\Handle::register();

/**
 * Enable local development services.
 */
$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';

/**
 * Show all error messages, with backtrace information.
 *
 * In case the error level could not be fetched from the database, as for
 * example the database connection failed, we rely only on this value.
 */
$config['system.logging']['error_level'] = 'verbose';

/**
 * Disable CSS and JS aggregation.
 */
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;

/**
 * Disable the render cache.
 *
 * Note: you should test with the render cache enabled, to ensure the correct
 * cacheability metadata is present. However, in the early stages of
 * development, you may want to disable it.
 *
 * This setting disables the render cache by using the Null cache back-end
 * defined by the development.services.yml file above.
 *
 * Only use this setting once the site has been installed.
 */
# $settings['cache']['bins']['render'] = 'cache.backend.null';

/**
 * Disable caching for migrations.
 *
 * Uncomment the code below to only store migrations in memory and not in the
 * database. This makes it easier to develop custom migrations.
 */
# $settings['cache']['bins']['discovery_migration'] = 'cache.backend.memory';

/**
 * Disable Internal Page Cache.
 *
 * Note: you should test with Internal Page Cache enabled, to ensure the correct
 * cacheability metadata is present. However, in the early stages of
 * development, you may want to disable it.
 *
 * This setting disables the page cache by using the Null cache back-end
 * defined by the development.services.yml file above.
 *
 * Only use this setting once the site has been installed.
 */
# $settings['cache']['bins']['page'] = 'cache.backend.null';

/**
 * Disable Dynamic Page Cache.
 *
 * Note: you should test with Dynamic Page Cache enabled, to ensure the correct
 * cacheability metadata is present (and hence the expected behavior). However,
 * in the early stages of development, you may want to disable it.
 */
# $settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';

/**
 * Allow test modules and themes to be installed.
 *
 * Drupal ignores test modules and themes by default for performance reasons.
 * During development it can be useful to install test extensions for debugging
 * purposes.
 */
# $settings['extension_discovery_scan_tests'] = TRUE;

/**
 * Enable access to rebuild.php.
 *
 * This setting can be enabled to allow Drupal's php and database cached
 * storage to be cleared via the rebuild.php page. Access to this page can also
 * be gained by generating a query string from rebuild_token_calculator.sh and
 * using these parameters in a request to rebuild.php.
 */
$settings['rebuild_access'] = TRUE;

/**
 * Skip file system permissions hardening.
 *
 * The system module will periodically check the permissions of your site's
 * site directory to ensure that it is not writable by the website user. For
 * sites that are managed with a version control system, this can cause problems
 * when files in that directory such as settings.php are updated, because the
 * user pulling in the changes won't have permissions to modify files in the
 * directory.
 */
$settings['skip_permissions_hardening'] = TRUE;

/**
 * Exclude modules from configuration synchronisation.
 *
 * On config export sync, no config or dependent config of any excluded module
 * is exported. On config import sync, any config of any installed excluded
 * module is ignored. In the exported configuration, it will be as if the
 * excluded module had never been installed. When syncing configuration, if an
 * excluded module is already installed, it will not be uninstalled by the
 * configuration synchronisation, and dependent configuration will remain
 * intact. This affects only configuration synchronisation; single import and
 * export of configuration are not affected.
 *
 * Drupal does not validate or sanity check the list of excluded modules. For
 * instance, it is your own responsibility to never exclude required modules,
 * because it would mean that the exported configuration can not be imported
 * anymore.
 *
 * This is an advanced feature and using it means opting out of some of the
 * guarantees the configuration synchronisation provides. It is not recommended
 * to use this feature with modules that affect Drupal in a major way such as
 * the language or field module.
 */
# $settings['config_exclude_modules'] = ['devel', 'stage_file_proxy'];

/**
 * Trusted host configuration.
 *
 * Drupal core can use the Symfony trusted host mechanism to prevent HTTP Host
 * header spoofing.
 *
 * To enable the trusted host mechanism, you enable your allowable hosts
 * in $settings['trusted_host_patterns']. This should be an array of regular
 * expression patterns, without delimiters, representing the hosts you would
 * like to allow.
 *
 * For example:
 * @code
 * $settings['trusted_host_patterns'] = array(
 *   '^www\.example\.com$',
 * );
 * @endcode
 * will allow the site to only run from www.example.com.
 *
 * If you are running multisite, or if you are running your site from
 * different domain names (eg, you don't redirect http://www.example.com to
 * http://example.com), you should specify all of the host patterns that are
 * allowed by your site.
 *
 * For example:
 * @code
 * $settings['trusted_host_patterns'] = array(
 *   '^example\.com$',
 *   '^.+\.example\.com$',
 *   '^example\.org$',
 *   '^.+\.example\.org$',
 * );
 * @endcode
 * will allow the site to run off of all variants of example.com and
 * example.org, with all subdomains included.
 */
$settings['trusted_host_patterns'] = [
    '^.+\.canada\.ca$',
    '^.+\.open\.local$',
    '^.+\.open-*\.local$',
    '^open\.local$',
    '^localhost$',
    '^127.0.0.1$',
];

# search domains
$settings['search_domain'] = [
    'en' => 'search.open.local:'. $_ENV["PROJECT_PORT"],
    'fr' => 'search.open.local:'. $_ENV["PROJECT_PORT"],
];

$settings['sd_search'] = [
    'en' => 'http://search.open.local:' . $_ENV["PROJECT_PORT"] . '/en/sd/id/',
    'fr' => 'http://search.open.local:' . $_ENV["PROJECT_PORT"] . '/fr/sd/id/',
];

# default domains
$settings['default_domain'] = [
    'en' => 'search.open.local:' . $_ENV["PROJECT_PORT"],
    'fr' => 'search.open.local:' . $_ENV["PROJECT_PORT"],
];

# default ati email address
$settings['ati_email'] = 'open-ouvert@tbs-sct.gc.ca';

# custom queue class
$settings['queue_service_ogp_queue'] = 'og_ext_cron.queue';
$settings['queue_reliable_service_ogp_queue'] = 'og_ext_cron.queue';

# GC Notify settings
$settings['gcnotify'] = [
  'base_uri' => 'UPDATE ME',
  'authorization' => 'ApiKey-v1 UPDATE ME',
  'template_id' => [
        'ati_records' => [
          'en' => 'UPDATE ME',
          'fr' => 'UPDATE ME',
          ],
        'feedback' => [
          'en' => 'UPDATE ME',
          'fr' => 'UPDATE ME',
          ],
        ],
  'bearer_token' => 'UPDATE ME',
];

# hide comments on external entities
$settings['external_comment']['exclude'] = [];