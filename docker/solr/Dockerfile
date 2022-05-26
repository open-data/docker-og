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

# Copy local_data volumes into data directory
# Set new files with correct user:group
ADD docker/config/solr/cores /var/solr/local_data
RUN mkdir -p /var/solr/data \
    && cp -R /var/solr/local_data/* /var/solr/data \
    && chown -R solr:root /var/solr/data \
    && chmod +x /usr/local/bin/start

CMD ["/usr/local/bin/start"]