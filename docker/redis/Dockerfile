FROM redis

USER root

RUN echo 'root:Docker!' | chpasswd

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

ARG USER_ID
ARG GROUP_ID

RUN if $(id -un ${USER_ID} >/dev/null 2>&1); then \
        userdel -f $(id -un ${USER_ID}); \
        if $(id -un redis-og >/dev/null 2>&1); then \
            usermod -u ${USER_ID} redis-og; \
        else \
            useradd -u ${USER_ID} redis-og; \
        fi \
    else \
        if $(id -un redis-og >/dev/null 2>&1); then \
            usermod -u ${USER_ID} redis-og; \
        else \
            useradd -u ${USER_ID} redis-og; \
        fi \
    fi \
    && \
    if [ $(getent group ${GROUP_ID}) ]; then \
        groupdel -f $(getent group ${GROUP_ID} | cut -d: -f1); \
        if [ $(getent group redis-og) ]; then \
            groupmod -g ${GROUP_ID} -n redis-og redis-og; \
        else \
            groupadd -g ${GROUP_ID} redis-og; \
        fi \
    else \
        if [ $(getent group redis-og) ]; then \
            groupmod -g ${GROUP_ID} -n redis-og redis-og; \
        else \
            groupadd -g ${GROUP_ID} redis-og; \
        fi \
    fi \
    && \
    chown redis-og:redis-og -R /data \
    && \
    chown redis-og:redis-og -R /etc/supervisor

RUN mkdir -p /data \
    && chown redis-og:redis-og -R /data \
    && chmod 777 /usr/local/bin/start

RUN echo 'redis-og:Docker!' | chpasswd \
    && usermod -a -G sudo redis-og \
    && echo 'redis-og    ALL=(ALL:ALL) ALL' >> /etc/sudoers

USER redis-og

CMD ["/usr/local/bin/start"]