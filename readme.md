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

## Build & Install

1. Build the container: `docker-compose build`
   * The initial build will take a long time.
   * You may receive some errors which can be disregarded unless your build fails.
   * A scenario that may happen is that the build will say it fails because of a final error message of your group ID already existing, this can be ignored.
1. Bring up the app and detach the shell: `docker-compose up -d`
1. Open a shell into the container: `docker-compose exec app bash`
1. Change permissions of this file so you can run it as a bash script: `chmod 775 install-local.sh`
1. Run the install script: `./install-local.sh`
   * There are some flags when running the script for patial installs:
      * `--skip-ssh`: will skip the installation and configuration of ssh which is needed for the repo pulls. Generally you can use this flag if you have the container running and have already installed SSH or do not need to use SSH again for the time being.
      * `--skip-db`: will skip the destruction and re-import of the database.
      * `--skip-repos`: will skip the pulling of all of the repositories. Generally, you can use this flag if you want to install a fresh database copy and want to keep all of your repositories and Drupal files.
1. Login here: `https://open.local/en/user/login`
   1. Username: `admin`
   1. Password: `12345678`

   
   