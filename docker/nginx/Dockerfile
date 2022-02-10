FROM nginx

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
        nginx \
        supervisor

# Supervisor
ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

# Nginx
ADD docker/config/nginx/nginx.conf /etc/nginx/nginx.conf
ADD docker/config/nginx/default /etc/nginx/sites-available/default

ADD docker/config/nginx/open.local /etc/nginx/sites-available/open.local
ADD docker/config/nginx/solr.open.local /etc/nginx/sites-available/solr.open.local
ADD docker/config/nginx/portal.open.local /etc/nginx/sites-available/portal.open.local
ADD docker/config/nginx/registry.open.local /etc/nginx/sites-available/registry.open.local

ADD docker/config/nginx/h5bp/ /etc/nginx/h5bp

ADD docker/start.sh /usr/local/bin/start

# Set files and directories permsissions and ownerships
RUN chmod +x /usr/local/bin/start

CMD ["/usr/local/bin/start"]