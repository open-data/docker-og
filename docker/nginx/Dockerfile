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
ADD docker/config/nginx/proxy /etc/nginx/sites-available/proxy
ADD docker/config/nginx/h5bp/ /etc/nginx/h5bp

ADD docker/start.sh /usr/local/bin/start

# Set files and directories permsissions and ownerships
RUN chmod +x /usr/local/bin/start \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

CMD ["/usr/local/bin/start"]