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

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
        if [ $(getent passwd | grep solr) ]; then \
            userdel -f solr; fi &&\
        if [ $(getent group | grep ${GROUP_ID}) ]; then \
            groupmod -g ${GROUP_ID} -n solr $(getent group ${GROUP_ID} | cut -d: -f1); else \
            groupadd -g ${GROUP_ID} solr; fi &&\
        if [ $(getent passwd | grep ${USER_ID}) ]; then \
            usermod -l solr -g solr $(getent passwd ${USER_ID} | cut -d: -f1); else \
            useradd -l -u ${USER_ID} -g solr solr; fi && \
        install -d -m 0755 -o solr -g solr /var/solr && \
        chown --changes --silent --no-dereference --recursive --from=33:33 ${USER_ID}:${GROUP_ID} /var/solr && \
        echo 'alias ls="ls $LS_OPTIONS"\n\
        alias ll="ls $LS_OPTIONS -l"\n\
        alias l="ls $LS_OPTIONS -lA"\n\
        alias home="cd /var/solr"' >> /var/solr/.bashrc &&\
        chown solr:solr /var/solr/.bashrc \
;fi


RUN chown solr:solr -R /var/solr

CMD ["/usr/local/bin/start"]