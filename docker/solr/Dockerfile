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

# Copy ckan schema
ADD docker/config/solr/ckan_schema.xml /ckan_schema.xml
RUN mkdir -p /etc/solr/conf && \
    mkdir -p /opt/solr/server/solr/configsets/_default/conf && \
    mkdir -p /opt/solr/server/conf && \
    cp /ckan_schema.xml /etc/solr/conf/schema.xml && \
    cp /ckan_schema.xml /opt/solr/server/solr/configsets/_default/conf/schema.xml && \
    cp /ckan_schema.xml /opt/solr/server/conf/schema.xml

# Set new files with correct user:group
RUN chown -R solr:root /var/solr/data && \
    chown solr:root /etc/solr/conf/schema.xml && \
    chown solr:root /opt/solr/server/solr/configsets/_default/conf/schema.xml && \
    chown solr:root /opt/solr/server/conf/schema.xml && \
    chmod +x /usr/local/bin/start

RUN /opt/solr/bin/solr start -force

CMD ["/usr/local/bin/start"]