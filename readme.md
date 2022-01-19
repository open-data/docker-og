# Local WordPress Setup for Open Government Drupal 8 Site

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
1. Use [mkcert](https://github.com/FiloSottile/mkcert) to make a certificate for nginx, if you're using Windows with WSL2, makes sure to make the certificates in Powershell running as an Administrator, not within WSL2:
   1. `mkcert open.local`
      1. Copy the cert to `docker/config/nginx/certs/open.local.pem`
         * IMPORTANT: make sure the file name is the same as above.
      1. Copy the private key to `docker/config/nginx/certs/open.local-key.pem`
         * IMPORTANT: make sure the file name is the same as above.
1. Copy `.docker.env.example` to `.docker.env`
1. Copy `example-drupal-local-settings.php` to `drupal-local-settings.php`
1. Copy `.env.example` to `.env`
   * If you need to, change your user and group to match the user and group your WSL2 user or Linux/Mac user employs:
      1. `id` <- this should get your current user ID and group ID in WSL2 or whatever shell you're using. If you're using WSL2 and only ever made your default user, it will likely be `1000`
1. Create a folder in the root of this repository called `backup`, in it, place the following files:
   1. `db.pgdump` <- the database backup for the Drupal site.
   1. `files.tgz` <- the compressed folder of the public files from the Drupal site.
1. Create a folder in the root of this repository called `postgres`. This folder will hold the data for imported databases to persist during Docker container restarts.
1. Create a folder in the root of this repository called `solr`. This folder will hold the data for imported indices to persist during Docker container restarts.

## Build & Install

1. Build the container: `docker-compose build`
   * The initial build will take a long time.
   * You may receive some errors which can be disregarded unless your build fails.
   * A scenario that may happen is that the build will say it fails because of a final error message of your group ID already existing, this can be ignored.
1. Bring up the app and detach the shell: `docker-compose up -d`
1. Open a shell into the container: `docker-compose exec app bash`
1. Change permissions of this file so you can run it as a bash script: `chmod 775 install-local.sh`
1. Run the install script: `./install-local.sh`
   * Select what you want to install:
      * `SSH (Required for Repositories)`: will install and configure the ssh command along with the ssh-agent and keys.
      * `Database`: will destroy the current database and import a fresh one from `backup/db.pgdump`
      * `Repositories`: will destroy all files inside of the `drupal` directory and pull all required repositories, download default settings files, copy `drupal-local-settings.php`, export the public files directory from `backup/files.tgz`, create the private files directory, set the correct file and directory ownerships and permissions, and create a local admin user for Drupal.
1. Login here: `https://open.local/en/user/login`
   1. Username: `admin.local`
   1. Password: `12345678`

   
   