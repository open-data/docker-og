FROM opendatacanada/solr:9

USER root

RUN /opt/solr/bin/solr stop -all

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
    chown solr:solr -R /var/solr

USER solr

CMD ["/usr/local/bin/start"]
