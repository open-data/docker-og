FROM solr

USER root

RUN /opt/solr/bin/solr stop -all

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
        supervisor

# Supervisor
ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

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