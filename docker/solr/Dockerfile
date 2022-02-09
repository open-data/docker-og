FROM solr

USER root

RUN /opt/solr/bin/solr stop -all

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
ADD docker/config/nginx/solr.open.local /etc/nginx/sites-available/solr.open.local
#ADD docker/config/nginx/mailhog /etc/nginx/sites-available/mailhog
ADD docker/config/nginx/h5bp/ /etc/nginx/h5bp

ADD docker/start.sh /usr/local/bin/start

# Create root data directory
RUN mkdir -p /var/solr/data

# Copy local_data volumes into data directory
ADD docker/config/solr/cores /var/solr/local_data
RUN cp -R /var/solr/local_data/* /var/solr/data

# Set new files with correct user:group
RUN chown -R solr:root /var/solr/data && \
    chmod +x /usr/local/bin/start

RUN /opt/solr/bin/solr start -force

CMD ["/usr/local/bin/start"]