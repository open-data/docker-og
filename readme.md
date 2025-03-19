# Local Docker Setup for Open Government Portal

| Table of Contents    |
| -------- |
| [Prerequisites](#prerequisites)  |
| [Recommendations](#recommendations) |
| [Docker Networking](#networking)    |
| [Project Prebuild](#prebuild)    |
| [Database and File Backups](#backups)    |
| [Build Containers](#build)    |
| [Installing Applications](#installation)    |
| [How to Use](#usage)    |
| [Postgres Version Upgrade](#upgrading-postgres)    |

## Prerequisites

* [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) ***if using Windows***
* [Docker](https://docs.docker.com/get-docker/)
* [docker-compose](https://docs.docker.com/compose/install/)
* [Git](https://github.com/git-guides/install-git)
   * You will also need your git configuration to be accessible to your user, located by default at `~/.gitconfig`. This will be attached to the Docker container so that the build scripts can pull the repositories.
   * If using WSL2, you will need to have this config set up inside of WSL2 for your WSL2 user.

## Recommendations

It is __highly__ recommended to use the [OG CLI](https://github.com/open-data/og-cli) tool to manage docker-og projects.

The OG CLI tool will give you an easier command-line interface to view, manage, and run Docker projects that use docker-og.

It will also allow you simpler git tooling and debugging.

## Networking

The docker-og scripts use port and IP octet renting from a pool of pre-defined ports and octets.

__Ports:__ 57000 - 57999
__IP Addresses:__ 172.25.__1__.0/24 - 172.25.__254__.0/24

You can see the project's important variables in the `.env` file after running the pre-build script.

## Prebuild

__Note:__ If using the `og-cli` tool, you do not need to run the `pre-build.sh` script.

Otherwise:

- __Run__ the pre build script with a Project ID: `./pre-build.sh example`

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

1. __Bring up__ any of the app containers docker container: `docker-compose up -d <django|drupal|ckan>`
1. __Run__ the install script in the docker container: `docker-compose exec <django|drupal|ckan> bash` and then `./install.sh`
   1. __Select__ `Databases (fixes missing databases, privileges, and users)`
   1. __Select__ `Test Databases (clones existing databases into empty ones)` _(Optional for destructive, unit tests)_

### Drupal (D10)

1. __Bring up__ the Drupal docker container: `docker-compose up -d drupal`
1. __Run__ the install script in the docker container: `docker-compose exec drupal bash` and then `./install.sh`
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

### CKAN (2.10)

1. __Bring up__ the CKAN Registry docker container: `docker-compose up -d ckan`
1. __Run__ the install script in the docker container: `docker-compose exec ckan bash` and then `./install.sh`
   1. __Select__ `CKAN (registry)`
   1. __Select__ what you want to install for CKAN Registry:
      * `Registry & Portal Databases`: will destroy the current `og_ckan_registry_local` and `og_ckan_portal_local` databases and import a fresh one from `backup/ckan_registry_db.pgdump` and `backup/ckan_portal_db.pgdump` respectively
         * Importing a database is optional, if the file does not exist, this step will be skipped automatically.
         * The database for CKAN Registry is not too large, however it has a lot of tables so importing the database will take a long time.
         * You may recieve warnings during the pg_restore: `out of shared memory`, this can be ignored, the import will just take longer.
      * `Registry & Portal Datastore Databases`: will destroy the current `og_ckan_registry_ds_local` and `og_ckan_portal_ds_local` databases and import a fresh one from `backup/ckan_registry_ds_db.pgdump` and `backup/ckan_portal_ds_db.pgdump` respectively
         * Importing a database is optional, if the file does not exist, this step will be skipped automatically.
         * The database for CKAN Registry is not too large, however it has a lot of tables so importing the database will take a long time.
         * You may recieve warnings during the pg_restore: `out of shared memory`, this can be ignored, the import will just take longer.
      * `Repositories`: will destroy all files inside of the `ckan` directory, and pull & install all required repositories related to CKAN and install them into the Python environment (along with their requirements).
      * `Downlod Wet-Boew Files`: will destroy all files inside of the `ckan/static_files` directory, and download and extract:
         * `wet-boew-cdn` into `ckan/static_files/wet-boew`
         * `themes-cdn` into `ckan/static_files/GCWeb`
      * `Set File Permissions`: will set the correct file and directory ownerships and permissions.
         * This will also set the correct database permissions for CKAN.
      * `Create Local User`: will create a local admin user for CKAN Registry & Portal.
      * `Import Organizations`: will dump the most recent Organizations from the ckanapi and import them into the database.
      * `Import Datasets`: will download the most recent dataset file and import them into the datase.
         * ***This will import all 30k+ resources. This may take a long time.***
      * `All`: will execute all of the above, use this for first time install or if you wish to re-install everything.
      * `Exit`: will exit the installation script.

### Django (Search App v2)

1. __Bring up__ the Django docker container: `docker-compose up -d django`
1. __Run__ the install script in the docker container: `docker-compose exec django ./install.sh`
   1. __Select__ `Django`
   1. __Select__ what you want to install for Django:
      * `OGC Django Search App (version 2)`: will destory the current Python virtual environment (if it exists) and install a fresh one, pull the ogc_search repository and copy `search-settings.py` to the environment.
      * `Static Files`: will download the required files, including the GCWeb theme and GCWeb Static release from the CDTS repository.
         * It will also copy files to the correct locations for serving them correctly.
      * `Searches`: will import all custom searches and their database definitions.
      * `Set File Permissions`: will set the correct file and directory ownerships and permissions.
      * `All`: will execute all of the above, use this for first time install or if you wish to re-install everything.
      * `Exit`: will exit the installation script.

## Usage

### Drupal (D10)

1. __Bring up__ the Drupal docker container: `docker-compose up -d drupal`
1. __Open__ a browser into: `http://open.local:<project port>`
1. Login here: `http://open.local:<project port>/en/user/login`
   1. Username: `admin.local`
   1. Password: `12345678`

Multisites are also available at:
  * `http://blog.open.local:<project port>`
  * `http://guides.open.local:<project port>`

### Solr (solr:9)

_The Solr container will automatically be brought up with the CKAN and Drupal containers._

1. __Bring up__ the Solr docker container: `docker-compose up -d solr`
1. __Open__ a browser into: `http://solr.open.local:<project port>`

### Postgres (postgres:13.14)

_The Postgres container will automatically be brought up with the CKAN and Drupal containers._

1. __Bring up__ the Postgres docker container: `docker-compose up -d postgres`
1. You can use the [pgAdmin](https://www.pgadmin.org/download/) software to connect to the Postgres container and query the databases.
1. For the connection info:
   * Hostname/address: `127.0.0.1`
   * Port: `<project database port>`
   * Username: `homestead`
   * Maintenance database: `postgres`

### CKAN (2.10)

1. __Bring up__ the CKAN docker container: `docker-compose up -d ckan`
1. __Open__ a browser into the Registry: `http://registry.open.local:<project port>`
   1. Login here: `http://registry.open.local:<project port>/en/user/login`
      1. Normal User:
         1. Username: `user_local`
         1. Password: `12345678`
      1. Sys Admin User:
         1. Username: `admin_local`
         1. Password: `12345678`
1. __Open__ a browser into the Portal: `http://open.local:<project port>/data/en/organization`
1. __Build__ the indices _(Optional)_:
   1. __Inventory:__ `ckan inventory rebuild --lenient -c $REGISTRY_CONFIG -f /srv/app/backup/inventory.csv`

### Django (Search App v2)

1. __Bring up__ the Django docker container: `docker-compose up -d django`
1. __Open__ a browser into: `http://search.open.local:<project port>`
   1. Login here: `http://search.open.local:<project port>/search/admin`
      1. Sys Admin User:
         1. Username: `admin_local`
         1. Password: `12345678!`

## Upgrading Postgres

If you need to upgrade major versions of PostgreSQL, you can dump all of the databases via the install script, and restore them  all after the PostgreSQL major version upgrade.

1. While still on your current version of PostgreSQL (viewable in the Dockerfile at `docker/postgres/Dockefile`).

    ```
    FROM postgres:9.6
    ```
1. __Bring up__ the Drupal or CKAN docker container: `docker-compose up -d <drupal or ckan>`
1. __Run__ the install script in the docker container: `docker-compose exec <drupal or ckan> bash` and then `./install.sh`
    1. __Select__ `Postgres Upgrade (dump and load existing databases for psql version upgrade)`
    1. __Select__ `Dump all existing databases (do PRIOR to Postgres version upgrade)` _(Do this prior to upgrading the Postgres major version)_
1. __Bring down__ all the containers: `docker-compose down`
1. Modify the Dockerfile `docker/postgres/Dockefile`:
    ```
    FROM postgres:13.14
    ```
1. __Rebuild__ the postgres container: `docker-compose build postgres`
1. __Run__ the install script in the docker container: `docker-compose exec <drupal or ckan> bash` and then `./install.sh`
    1. __Select__ `Postgres Upgrade (dump and load existing databases for psql version upgrade)`
    1. __Select__ `Restore all databases (do AFTER Postgres version upgrade)` _(Do this after upgrading the Postgres major version)_
