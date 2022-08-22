FROM redis

USER root

RUN echo 'root:Docker!' | chpasswd

ARG USER_ID
ARG GROUP_ID

RUN if $(id -un ${USER_ID} >/dev/null 2>&1); then \
        userdel -f $(id -un ${USER_ID}); \
        if $(id -un redis >/dev/null 2>&1); then \
            usermod -u ${USER_ID} redis; \
        else \
            useradd -u ${USER_ID} redis; \
        fi \
    else \
        if $(id -un redis >/dev/null 2>&1); then \
            usermod -u ${USER_ID} redis; \
        else \
            useradd -u ${USER_ID} redis; \
        fi \
    fi \
    && \
    if [ $(getent group ${GROUP_ID}) ]; then \
        groupdel -f $(getent group ${GROUP_ID} | cut -d: -f1); \
        if [ $(getent group redis) ]; then \
            groupmod -g ${GROUP_ID} -n redis redis; \
        else \
            groupadd -g ${GROUP_ID} redis; \
        fi \
    else \
        if [ $(getent group redis) ]; then \
            groupmod -g ${GROUP_ID} -n redis redis; \
        else \
            groupadd -g ${GROUP_ID} redis; \
        fi \
    fi \
    && \
    chown redis:redis -R /data

RUN echo 'redis:Docker!' | chpasswd \
    && usermod -a -G sudo redis

USER redis