# Local WordPress Setup for Irdeto

1. Create the following hosts file entries:
    1. `127.0.0.1 open.local`
    1. `127.0.0.1 mailhog.local`
1. Use [mkcert](https://github.com/FiloSottile/mkcert) to make a certificate for nginx, if you're using Windows with WSL2, makes sure to make the certificates in Powershell running as an Administrator, not within WSL2:
   1. `mkcert open.local`
      1. Copy the cert to `docker/config/nginx/certs/open.local.pem`
      1. Copy the private key to `docker/config/nginx/certs/open.local-key.pem`
1. Copy `.docker.env.example` to `.docker.env`
1. Copy `example-drupal-local-settings.php` to `drupal-local-settings.php`
1. Copy `.env.example` to `.env` - if you need to, change your user and group to match the user and group your WSL2 user or Linux/Mac user employs:
   1. `id` <-- this should get your current user ID and group ID in WSL2 or whatever shell you're using, then set the .env variables for user and group ID to the appropriate ones.  If you're using WSL2 and only ever made your default user, it will likely be `1000`
1. Create a folder in the root of this repository called `backup`, in it, place the following files:
   1. `db.pgdump` <-- the database backup
1. Build the container: `docker-compose build`
   * The initial build may take a long time.
   * You may receive some errors which can be disregarded unless your build fails.
1. Bring up the app and detach the shell: `docker-compose up -d`
1. Open a shell into the container: `docker-compose exec app bash`
1. Change permissions of this file so you can run it as a bash script: `chmod 775 install-local.sh`
1. Run the install script: `./install-local.sh`
1. Login here: `https://open.local/en/user/login`
   1. Username: `admin`
   1. Password: `12345678`

   
   