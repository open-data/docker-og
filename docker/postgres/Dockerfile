FROM postgres:9.6

USER root

RUN echo 'root:Docker!' | chpasswd

ARG USER_ID
ARG GROUP_ID

RUN if $(id -un ${USER_ID} >/dev/null 2>&1); then \
        userdel -f $(id -un ${USER_ID}); \
        if $(id -un postgres >/dev/null 2>&1); then \
            usermod -u ${USER_ID} postgres; \
        else \
            useradd -u ${USER_ID} postgres; \
        fi \
    else \
        if $(id -un postgres >/dev/null 2>&1); then \
            usermod -u ${USER_ID} postgres; \
        else \
            useradd -u ${USER_ID} postgres; \
        fi \
    fi \
    && \
    if [ $(getent group ${GROUP_ID}) ]; then \
        groupdel -f $(getent group ${GROUP_ID} | cut -d: -f1); \
        if [ $(getent group postgres) ]; then \
            groupmod -g ${GROUP_ID} -n postgres postgres; \
        else \
            groupadd -g ${GROUP_ID} postgres; \
        fi \
    else \
        if [ $(getent group postgres) ]; then \
            groupmod -g ${GROUP_ID} -n postgres postgres; \
        else \
            groupadd -g ${GROUP_ID} postgres; \
        fi \
    fi \
    && \
    chown postgres:postgres -R /var/lib/postgresql

RUN echo 'postgres:Docker!' | chpasswd \
    && usermod -a -G sudo postgres \
    && echo 'postgres    ALL=(ALL:ALL) ALL' >> /etc/sudoers

USER postgres