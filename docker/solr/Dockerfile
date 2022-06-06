FROM solr:8

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
    && chown -R solr:solr /var/solr/data \
    && chmod +x /usr/local/bin/start

ARG USER_ID
ARG GROUP_ID

RUN if [[ ! $(id -un ${USER_ID}) == "solr" ]]; then \
        userdel -f $(id -un ${USER_ID}); \
        usermod -u ${USER_ID} solr; \
    else \
        usermod -u ${USER_ID} solr; \
    fi \
    && \
    if [[ ! $(id -gn ${GROUP_ID}) == "root" ]]; then \
        groudel -f $(id -gn ${GROUP_ID}); \
        groupmod -g ${GROUP_ID} -n root root; \
    else \
        groupmod -g ${GROUP_ID} -n root root; \
    fi \
    && \
    chown solr:root -R /var/solr

CMD ["/usr/local/bin/start"]