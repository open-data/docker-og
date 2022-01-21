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

1. Create the following hosts file entries:
    1. `127.0.0.1 open.local`
    1. `127.0.0.1 mailhog.local`
1. Use [mkcert](https://github.com/FiloSottile/mkcert) to make a certificate for nginx(Drupal), if you're using Windows with WSL2, makes sure to make the certificates in Powershell running as an Administrator, not within WSL2:
   1. cd inside of the `docker/config/nginx/certs` directory.
   1. Generate the pem chain: `mkcert -cert-file open.local.pem -key-file open.local-key.pem open.local`
1. Generate keystores and certs for Solr SSL:
   1. cd inside of the `docker/config/solr/certs` directory.
   1. Generate JKS keystore: `keytool -genkeypair -alias solr -keyalg RSA -keysize 2048 -keypass secret -storepass secret -validity 9999 -keystore solr.keystore.jks -ext SAN=DNS:localhost,IP:127.0.0.1,IP:192.168.1.3 -dname "CN=localhost, OU=Organizational Unit, O=Organization, L=Location, ST=State, C=Country"`
   1. Generate P12 keystore from JKS keystore: `keytool -importkeystore -srckeystore solr.keystore.jks -destkeystore solr.keystore.p12 -srcstoretype jks -deststoretype pkcs12`
      1. You will be prompted a few times for a password, use the password from the first command: `secret`.
   1. Generate pem chain from P12 keysotre: 
      1. Generate private key: `openssl pkcs12 -in solr.keystore.p12 -out solr-key.pem -nodes -nocerts`
         1. You will be prompted for a password, use the password from the first command: `secret`.
         1. The outputted file will contain some lines like "Bag Attributes...Key Attributes...", edit the file and delete these lines
      1. Generate certificate: `openssl pkcs12 -in solr.keystore.p12 -out solr.pem -nokeys`
         1. You will be prompted for a password, use the password from the first command: `secret`.
         1. The outputted file will contain some lines like "Bag Attributes...Key Attributes...", edit the file and delete these lines
1. Copy `.docker.env.example` to `.docker.env`
1. Copy `example-drupal-local-settings.php` to `drupal-local-settings.php`
1. Copy `example-ckan.ini` to `ckan.ini`
1. Copy `.env.example` to `.env`
   * If you need to, change your user and group to match the user and group your WSL2 user or Linux/Mac user employs:
      1. `id` <- this should get your current user ID and group ID in WSL2 or whatever shell you're using. If you're using WSL2 and only ever made your default user, it will likely be `1000`
1. Create a folder in the root of this repository called `backup`, in it, place the following files:
   1. `drupal_db.pgdump` <- the database backup for the Drupal site.
   1. `drupal_files.tgz` <- the compressed folder of the public files from the Drupal site.
1. Create a folder in the root of this repository called `postgres`. This folder will hold the data for imported databases to persist during Docker container restarts.
1. Create a folder in the root of this repository called `solr`. This folder will hold the data for imported indices to persist during Docker container restarts.

## Build

1. Build the container: `docker-compose build`
   * The initial build will take a long time.
1. Bring up the app and detach the shell: `docker-compose up -d` to make sure that all the containers can start correctly.
   * The initial up may take a long time.
   * To stop all the containers: `docker-compose down`

## Installation

### Databases

Though there is an initialization script to create the databases on the initial up of the `postgres` container, this script only runs once. After you have built the containers once, this script will no longer run. To fix any issues with missing databases, users, or password:

1. Bring up the Drupal docker container: `docker-compose up -d drupal`
1. Open a shell into the container: `docker-compose exec drupal bash`
1. Change permissions of this file (if not already done) so you can run it as a bash script: `chmod 775 install-local.sh`
1. Run the install script: `./install-local.sh`
   1. Select `Databases (fixes missing databases, privileges, and users)`

### Drupal

1. Bring up the Drupal docker container: `docker-compose up -d drupal`
1. Open a shell into the container: `docker-compose exec drupal bash`
1. Change permissions of this file (if not already done) so you can run it as a bash script: `chmod 775 install-local.sh`
1. Run the install script: `./install-local.sh`
   1. Select `Drupal`
   1. Select what you want to install for Drupal:
      * `SSH (Required for Repositories)`: will install and configure the ssh command along with the ssh-agent and keys.
      * `Database`: will destroy the current database and import a fresh one from `backup/drupal_db.pgdump`
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

1. Bring up the CKAN docker container: `docker-compose up -d ckan`
1. Open a shell into the container: `docker-compose exec ckan bash`
1. Change permissions of this file (if not already done) so you can run it as a bash script: `chmod 775 install-local.sh`
1. Run the install script: `./install-local.sh`
   1. Select `CKAN`
   1. Select what you want to install for CKAN:
      * `SSH (Required for Repositories)`: will install and configure the ssh command along with the ssh-agent and keys.
      * `Database`: will destroy the current database and import a fresh one from `backup/ckan_db.pgdump`
      * `Repositories`: will destroy all files inside of the `ckan` directory and pull all required repositories related to CKAN.
      * `Set File Permissions`: will set the correct file and directory ownerships and permissions.
      * `All`: will execute all of the above, use this for first time install or if you wish to re-install everything.
      * `Exit`: will exit the installation script.
   
   