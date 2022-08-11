# Local Docker Setup for Open Government Portal

## Prerequisites

* [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) ***if using Windows***
* [Docker](https://docs.docker.com/get-docker/)
* [docker-compose](https://docs.docker.com/compose/install/)
* [Git](https://github.com/git-guides/install-git)
   * You will also need your git configuration to be accessible to your user, located by default at `~/.gitconfig`. This will be attached to the Docker container so that the build scripts can pull the repositories.
   * If using WSL2, you will need to have this config set up inside of WSL2 for your WSL2 user.

## Prebuild

1. __Run__ the pre build script with a Project ID: `./pre-build.sh example`
1. __portal.ini__ and __registry.ini__ files:
   1. __Change__ `ckanext.cloudstorage.container_name` value to `<your user name>-dev`
   1. __Change__ `ckanext.cloudstorage.driver_options` secret value to the secret key for `opencanadastaging`
   1. __Change__ `ckanext.gcnotify.secret_key` value to `<your GC Notify secret key>`
   1. __Change__ `ckanext.gcnotify.base_url` value to the GC Notify base url
   1. __Change__ `ckanext.gcnotify.template_ids` dict values to the development template IDs
   1. __Change__ `canada.notification_new_user_email` value to `<your email>`

### Backups

#### Global

If you do not have any backups in the root `backup` directory, the installation scripts will look for the backup files in `/opt/tbs/docker/backup`

1. __Create the directory__ `sudo mkdir -p /opt/tbs/docker/backup`
1. __Set permissions__ `sudo chmod 777 -R /opt/tbs/docker/backup`
1. __/opt/tbs/docker/backup__ directory. In it, place the following files:
   * __For Drupal:__
      1. `drupal_db.pgdump` _(Required)_ <- the database backup for the Drupal site.
      1. `drupal_files.tgz` _(Required)_ <- the compressed folder of the public files from the Drupal site.
   * __For CKAN:__
      1. `ckan_portal_db.pgdump` _(Optional)_ <- the database backup for the CKAN Portal app.
      1. `ckan_portal_ds_db.pgdump` _(Optional)_ <- the database backup for the CKAN Portal Datastore.
      1. `ckan_registry_db.pgdump` _(Optional)_ <- the database backup for the CKAN Registry app.
      1. `ckan_registry_ds_db.pgdump` _(Optional)_ <- the database backup for the CKAN Registry Datastore.
   * __For Solr:__
      1. `inventory.csv` _(Optional)_ <- Open Data Inventory data set csv file.

#### Per Project

To override the use of the global backups during the installation scripts, place any of the above files into the root `backup` directory.

## Build

1. __Build__ the container: `docker-compose build`
   * ***The initial build will take a long time.***
   * If you are rebuilding and receive errors such as `max depth exceeded`, you may need to destroy all of the docker images (`docker image prune -a`) and then run the above build command. Please note that this will also destroy any other docker images you have on your machine.
   * If your build fails with errors regarding failure of resolving domains, restart your docker service (`sudo service docker restart`).
1. __Bring up__ the app and detach the shell: `docker-compose up -d` to make sure that all the containers can start correctly.
   * ***The initial up may take a long time.***
   * To stop all the containers: `docker-compose down`

## Installation

### Databases

Though there is an initialization script to create the databases on the initial up of the `postgres` container, this script only runs once. After you have built the containers once, this script will no longer run. To fix any issues with missing databases, users, or password:

1. __Bring up__ the Drupal or CKAN docker container: `docker-compose up -d <drupal or ckan>`
1. __Run__ the install script in the docker container: `docker-compose exec <drupal or ckan> ./install.sh`
   1. __Select__ `Databases (fixes missing databases, privileges, and users)`

### Drupal

1. __Bring up__ the Drupal docker container: `docker-compose up -d drupal`
1. __Run__ the install script in the docker container: `docker-compose exec drupal ./install.sh`
   1. __Select__ `Drupal`
   1. __Select__ what you want to install for Drupal:
      * `Database`: will destroy the current `og_drupal_local` database and import a fresh one from `backup/drupal_db.pgdump`
      * `Repositories`: will destroy all files inside of the `drupal` directory and pull all required repositories related to Drupal.
      * `Local Files`: will destroy all Drupal local files and extract the directory from `backup/drupal_files.tgz`.
      * `Set File Permissions (also creates missing directories)`: will download default settings files, copy `drupal-local-settings.php` create the private files directory, and set the correct file and directory ownerships and permissions.
      * `Create Local User`: will create a local admin user for Drupal.
      * `All`: will execute all of the above, use this for first time install or if you wish to re-install everything.
      * `Exit`: will exit the installation script.
1. Login here: `https://open.local/en/user/login`
   1. Username: `admin.local`
   1. Password: `12345678`

### CKAN

#### Registry

1. __Bring up__ the CKAN Registry docker container: `docker-compose up -d ckan`
1. __Run__ the install script in the docker container: `docker-compose exec ckan ./install.sh`
   1. __Select__ `CKAN (registry)`
   1. __Select__ what you want to install for CKAN Registry:
      * `Registry Database`: will destroy the current `og_ckan_registry_local` database and import a fresh one from `backup/ckan_registry_db.pgdump`
         * Importing a database is optional, if the file does not exist, this step will be skipped automatically.
         * The database for CKAN Registry is not too large, however it has a lot of tables so importing the database will take a long time.
         * You may recieve warnings during the pg_restore: `out of shared memory`, this can be ignored, the import will just take longer.
      * `Registry Datastore Database`: will destroy the current `og_ckan_registry_ds_local` database and import a fresh one from `backup/ckan_registry_ds_db.pgdump`
         * Importing a database is optional, if the file does not exist, this step will be skipped automatically.
         * The database for CKAN Registry is not too large, however it has a lot of tables so importing the database will take a long time.
         * You may recieve warnings during the pg_restore: `out of shared memory`, this can be ignored, the import will just take longer.
      * `Repositories`: will destroy all files inside of the `ckan/registry` directory, and pull & install all required repositories related to CKAN and install them into the Python environment (along with their requirements).
      * `Downlod Wet-Boew Files`: will destroy all files inside of the `ckan/static_files` direcotry, and download and extract:
         * `wet-boew-cdn` into `ckan/static_files/wet-boew`
         * `themes-cdn` into `ckan/static_files/GCWeb`
      * `Set File Permissions`: will set the correct file and directory ownerships and permissions.
         * This will also set the correct database permissions for CKAN.
      * `Create Local User`: will create a local admin user for CKAN Registry.
      * `Import Organizations`: will dump the most recent Organizations from the ckanapi and import them into the database.
      * `Import Datasets`: will download the most recent dataset file and import them into the datase.
         * ***This will import all 30k+ resources. This may take a long time.***
      * `All`: will execute all of the above, use this for first time install or if you wish to re-install everything.
      * `Exit`: will exit the installation script.

#### Portal

1. __Bring up__ the CKAN Portal docker container: `docker-compose up -d ckanapi`
1. __Run__ the install script in the docker container: `docker-compose exec ckanapi ./install.sh`
   1. __Select__ `CKAN (portal)`
   1. __Select__ what you want to install for CKAN Portal:
      * `Portal Database`: will destroy the current `og_ckan_portal_local` database and import a fresh one from `backup/ckan_portal_db.pgdump`
         * Importing a database is optional, if the file does not exist, this step will be skipped automatically.
         * The database for CKAN is large, so importing the database will take a long time.
         * You may recieve warnings during the pg_restore: `out of shared memory`, this can be ignored, the import will just take longer.
      * `Portal Datastore Database`: will destroy the current `og_ckan_portal_ds_local` database and import a fresh one from `backup/ckan_portal_ds_db.pgdump`
         * Importing a database is optional, if the file does not exist, this step will be skipped automatically.
         * The database for CKAN is large, so importing the database will take a long time.
         * You may recieve warnings during the pg_restore: `out of shared memory`, this can be ignored, the import will just take longer.
      * `Repositories`: will destroy all files inside of the `ckan/portal` directory, and pull & install all required repositories related to CKAN and install them into the Python environment (along with their requirements).
      * `Downlod Wet-Boew Files`: will destroy all files inside of the `ckan/static_files` direcotry, and download and extract:
         * `wet-boew-cdn` into `ckan/static_files/wet-boew`
         * `themes-cdn` into `ckan/static_files/GCWeb`
      * `Set File Permissions`: will set the correct file and directory ownerships and permissions.
         * This will also set the correct database permissions for CKAN.
      * `Create Local User`: will create a local admin user for CKAN Portal.
      * `Import Organizations`: will dump the most recent Organizations from the ckanapi and import them into the database.
      * `Import Datasets`: will download the most recent dataset file and import them into the datase.
         * ***This will import all 30k+ resources. This may take a long time.***
      * `All`: will execute all of the above, use this for first time install or if you wish to re-install everything.
      * `Exit`: will exit the installation script.

#### Django

1. __Bring up__ the Django docker container: `docker-compose up -d django`
1. __Run__ the install script in the docker container: `docker-compose exec django ./install.sh`
   1. __Select__ `Django`
   1. __Select__ what you want to install for Django:
      * `OGC Django Search App (version 1)`: will destory the current Python virtual environment (if it exists) and install a fresh one, pull the ogc_search repository and copy `search-settings.py` to the environment.
         * This will also download the required CKAN yaml and json files.
      * `Static Files`: will download the required files, including the GCWeb theme and GCWeb Static release from the CDTS repository.
         * It will also copy files to the correct locations for serving them correctly.
      * `Set File Permissions`: will set the correct file and directory ownerships and permissions.
      * `All`: will execute all of the above, use this for first time install or if you wish to re-install everything.
      * `Exit`: will exit the installation script.
   
## Usage

### Drupal

1. __Bring up__ the Drupal docker container: `docker-compose up -d drupal`
1. __Open__ a browser into: `http://open-${PROJECT ID}.local`
1. Login here: `http://open-${PROJECT ID}.local/en/user/login`
   1. Username: `admin.local`
   1. Password: `12345678`

### Solr

_The Solr container will automatically be brought up with the CKAN and Drupal containers._

1. __Bring up__ the Solr docker container: `docker-compose up -d solr`
1. __Open__ a browser into: `http://solr.open-${PROJECT ID}.local`

### Postgres

_The Postgres container will automatically be brought up with the CKAN and Drupal containers._

1. __Bring up__ the Postgres docker container: `docker-compose up -d postgres`
1. You can use the [pgAdmin](https://www.pgadmin.org/download/) software to connect to the Postgres container and query the databases.
1. For the connection info:
   * Hostname/address: `127.0.0.1`
   * Port: `15438`
   * Username: `homestead`
   * Maintenance database: `postgres`

### CKAN

#### Registry

1. __Bring up__ the CKAN Registry docker container: `docker-compose up -d ckan`
1. __Open__ a browser into: `http://registry.open-${PROJECT ID}.local`
   1. Login here: `http://registry.open-${PROJECT ID}.local/en/user/login`
      1. Normal User:
         1. Username: `user_local`
         1. Password: `12345678`
      1. Sys Admin User:
         1. Username: `admin_local`
         1. Password: `12345678`
1. __Build__ the indices _(Optional)_:
   1. __Inventory:__ `paster --plugin=ckanext-canada inventory rebuild --lenient -c $REGISTRY_CONFIG -f /srv/app/backup/inventory.csv`

#### Portal

1. __Bring up__ the CKAN Portal docker container: `docker-compose up -d ckanapi`
1. __Open__ a browser into: `http://open-${PROJECT ID}.local/data/en/dataset`

### Django

1. __Bring up__ the Django docker container: `docker-compose up -d django`
1. __Open__ a browser into: `http://search.open-${PROJECT ID}.local`
   