# Local Docker Setup for Open Government Portal

## Prerequisites

* [mkcert](https://github.com/FiloSottile/mkcert)
   * Make sure to run `mkcert -install` after installing mkcert.
   * If using WSL2, make sure to install mkcert within Windows and not inside of WSL2.
   * mkcert has to be run outside of WSL2 because your web browsers are not running inside of WSL2.
* [Docker](https://docs.docker.com/get-docker/)
* [docker-compose](https://docs.docker.com/compose/install/)
* [Git](https://github.com/git-guides/install-git)
   * You will also need your git configuration to be global, located by default at `~/.gitconfig`. This will be attached to the Docker container so that the build scripts can pull the repositories.
   * If using WSL2, you will need to have this global config set up inside of WSL2.
* SSH Keys
   * You will need SSH keys generated in their default location at `~/.ssh`. This will be attached to the Docker container so that the build script can have access to pull the repositories.
      * If you do not have SSH keys generated for your machine, you can generate some with `ssh-keygen -t rsa` and you can keep clicking enter for no password and to put them in their default location.
   * If using WSL2, you will need the SSH keys inside of WSL2.
   * You will need to add your public key to your Github profile, [instructions here.](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
* Write access to your host file found at `/etc/hosts`.

## Prebuild

1. __Create__ new Docker networks: 
   1. `docker network create og-proxy-network`
   1. `docker network create og-local-network`
1. __Create__ the following hosts file(`/etc/hosts`) entries:
    1. `127.0.0.1 open.local`
    1. `127.0.0.1 registry.open.local`
    1. `127.0.0.1 portal.open.local`
    1. `127.0.0.1 solr.open.local`
1. __Use [mkcert](https://github.com/FiloSottile/mkcert)__ to make a certificate for nginx(Drupal, CKAN, and Solr) and solr if you're using Windows with WSL2, makes sure to make the certificates in Powershell running as an Administrator, not within WSL2:
   * __nginx(Drupal):__
      1. cd inside of the `docker/config/nginx/certs` directory.
      1. Generate the pem chain: `mkcert -cert-file open.local.pem -key-file open.local-key.pem open.local registry.open.local portal.open.local solr.open.local 127.0.0.1 localhost ::1 ::5001 ::5000 ::8981 ::8983 ::4430`
   * __solr:__
      1. cd inside of the `docker/config/solr/certs` directory.
      1. Generate the PKCS12 keystore: `mkcert -pkcs12 -p12-file solr.p12 127.0.0.1 localhost solr ::1 ::8981 ::8983`
1. __Copy__ `.docker.env.example` to `.docker.env`
1. __Copy__ `example-drupal-local-settings.php` to `drupal-local-settings.php`
1. __Copy__ `example-drupal-services.yml` to `drupal-services.yml`
1. __Copy__ `example-ckan.ini` to `ckan.ini`
1. __Copy__ `example-portal.ini` to `portal.ini`
1. __Copy__ `example-registry.ini` to `registry.ini`
1. __Copy__ `.env.example` to `.env`
   1. You will need to __update__ the `CA_LOCAL_ROOT` variable to the output of this command: `mkcert -CAROOT`
   1. If you need to, change your user and group to match the user and group your WSL2 user or Linux/Mac user employs:
      1. `id` <- this should get your current user ID and group ID in WSL2 or whatever shell you're using. If you're using WSL2 and only ever made your default user, it will likely be `1000`
1. __Create__ a folder in the root of this repository called `backup`, in it, place the following files:
   * __For Drupal:__
      1. `drupal_db.pgdump` <- the database backup for the Drupal site.
      1. `drupal_files.tgz` <- the compressed folder of the public files from the Drupal site.
   * __For CKAN:__
      1. `ckan_portal_db.pgdump` <- the database backup for the CKAN Portal app.
      1. `ckan_portal_ds_db.pgdump` <- the database backup for the CKAN Portal Datastore.
      1. `ckan_registry_db.pgdump` <- the database backup for the CKAN Registry app.
      1. `ckan_registry_ds_db.pgdump` <- the database backup for the CKAN Registry Datastore.
   * __For Solr:__
      1. `inventory.csv` <- Open Data Inventory data set csv file.
1. __Create__ a folder in the root of this repository called `postgres`. This folder will hold the data for imported databases to persist during Docker container restarts.
1. __Create__ a folder in the root of this repository called `solr`. This folder will hold the data for imported indices to persist during Docker container restarts.
1. __Create__ a folder in the root of this repository called `nginx`. This folder will hold the nginx logs for the Docker environments.
   * By default, the volume is commented out in the `docker-compose.yml` file as the nginx logs can get large. You can uncomment the lines if you are having issues with nginx.

## Build

1. __Build__ the container: `docker-compose build`
   * ***The initial build will take a long time.***
   * If you are rebuilding and receive errors such as `max depth exceeded`, you may need to destroy all of the docker images (`docker image prune -a`) and then run the above build command. Please note that this will also destroy any other docker images you have on your machine.
1. __Bring up__ the app and detach the shell: `docker-compose up -d` to make sure that all the containers can start correctly.
   * ***The initial up may take a long time.***
   * To stop all the containers: `docker-compose down`

## Installation

### Databases

Though there is an initialization script to create the databases on the initial up of the `postgres` container, this script only runs once. After you have built the containers once, this script will no longer run. To fix any issues with missing databases, users, or password:

1. __Bring up__ the Drupal or CKAN docker container: `docker-compose up -d <drupal or ckan>`
1. __Open a shell__ into the container: `docker-compose exec <drupal or ckan> bash`
1. __Change permissions__ of this file (if not already done) so you can run it as a bash script: `chmod 775 install-local.sh`
1. __Run__ the install script: `./install-local.sh`
   1. __Select__ `Databases (fixes missing databases, privileges, and users)`

### Drupal

1. __Bring up__ the Drupal docker container: `docker-compose up -d drupal`
1. __Open a shell__ into the container: `docker-compose exec drupal bash`
1. __Change__ permissions of this file (if not already done) so you can run it as a bash script: `chmod 775 install-local.sh`
1. __Run__ the install script: `./install-local.sh`
   1. __Select__ `Drupal`
   1. __Select__ what you want to install for Drupal:
      * `SSH (Required for Repositories)`: will install and configure the ssh command along with the ssh-agent and keys.
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

1. __Bring up__ the CKAN docker container: `docker-compose up -d ckan`
1. __Open a shell__ into the container: `docker-compose exec ckan bash`
1. __Change__ permissions of this file (if not already done) so you can run it as a bash script: `chmod 775 install-local.sh`
1. __Run__ the install script: `./install-local.sh`
   1. __Select__ `CKAN`
   1. __Select__ what you want to install for CKAN:
      * `SSH (Required for Repositories)`: will install and configure the ssh command along with the ssh-agent and keys.
      * `Portal Database`: will destroy the current `og_ckan_portal_local` database and import a fresh one from `backup/ckan_portal_db.pgdump`
         * The database for CKAN is large, so importing the database will take a long time.
         * You may recieve warnings during the pg_restore: `out of shared memory`, this can be ignored, the import will just take longer.
      * `Portal Datastore Database`: will destroy the current `og_ckan_portal_ds_local` database and import a fresh one from `backup/ckan_portal_ds_db.pgdump`
         * The database for CKAN is large, so importing the database will take a long time.
         * You may recieve warnings during the pg_restore: `out of shared memory`, this can be ignored, the import will just take longer.
      * `Registry Database`: will destroy the current `og_ckan_registry_local` database and import a fresh one from `backup/ckan_registry_db.pgdump`
         * The database for CKAN Registry is not too large, however it has a lot of tables so importing the database will take a long time.
         * You may recieve warnings during the pg_restore: `out of shared memory`, this can be ignored, the import will just take longer.
      * `Registry Datastore Database`: will destroy the current `og_ckan_registry_ds_local` database and import a fresh one from `backup/ckan_registry_ds_db.pgdump`
         * The database for CKAN Registry is not too large, however it has a lot of tables so importing the database will take a long time.
         * You may recieve warnings during the pg_restore: `out of shared memory`, this can be ignored, the import will just take longer.
      * `Repositories`: will destroy all files inside of the `ckan/default` directory, and pull & install all required repositories related to CKAN and install them into the Python environment (along with their requirements).
      * `Set File Permissions`: will set the correct file and directory ownerships and permissions.
      * `All`: will execute all of the above, use this for first time install or if you wish to re-install everything.
      * `Exit`: will exit the installation script.
   
## Usage

### Solr

1. __Bring up__ the Solr docker container: `docker-compose up -d solr`
1. __Open__ a browser into: `https://solr.open.local`
### CKAN

1. __Bring up__ the CKAN docker container: `docker-compose up -d ckan`
1. __Open a shell__ into the container: `docker-compose exec ckan bash`
1. __Build__ the indices:
   1. __Inventory:__ `paster --plugin=ckanext-canada inventory rebuild --lenient -c $REGISTRY_CONFIG -f /srv/app/backup/inventory.csv`
   