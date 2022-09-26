FROM solr:8

USER root

RUN echo 'root:Docker!' | chpasswd

RUN /opt/solr/bin/solr stop -all

RUN chmod 777 /etc/resolv.conf \
    && apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
        sudo \
        systemd \
        sysvinit-utils \
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
    && chmod 777 /usr/local/bin/start

ARG USER_ID
ARG GROUP_ID

RUN if $(id -un ${USER_ID} >/dev/null 2>&1); then \
        userdel -f $(id -un ${USER_ID}); \
        if $(id -un solr >/dev/null 2>&1); then \
            usermod -u ${USER_ID} solr; \
        else \
            useradd -u ${USER_ID} solr; \
        fi \
    else \
        if $(id -un solr >/dev/null 2>&1); then \
            usermod -u ${USER_ID} solr; \
        else \
            useradd -u ${USER_ID} solr; \
        fi \
    fi \
    && \
    if [ $(getent group ${GROUP_ID}) ]; then \
        groupdel -f $(getent group ${GROUP_ID} | cut -d: -f1); \
        if [ $(getent group solr) ]; then \
            groupmod -g ${GROUP_ID} -n solr solr; \
        else \
            groupadd -g ${GROUP_ID} solr; \
        fi \
    else \
        if [ $(getent group solr) ]; then \
            groupmod -g ${GROUP_ID} -n solr solr; \
        else \
            groupadd -g ${GROUP_ID} solr; \
        fi \
    fi \
    && \
    chown solr:solr -R /var/solr \
    && \
    chown solr:solr -R /etc/supervisor

RUN echo 'solr:Docker!' | chpasswd \
    && usermod -a -G sudo solr \
    && echo 'solr    ALL=(ALL:ALL) ALL' >> /etc/sudoers

USER solr

CMD ["/usr/local/bin/start"]