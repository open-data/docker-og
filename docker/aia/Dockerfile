FROM node:slim

USER root

RUN echo 'root:Docker!' | chpasswd

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
        supervisor \
        build-essential \
        procps \
        sudo \
        curl \
		    git \
    && curl --insecure -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | GIT_SSL_NO_VERIFY=1 bash \
    && . ~/.bashrc \
    && NVM_NODEJS_ORG_MIRROR=http://nodejs.org/dist nvm install 16 \
    && nvm use 16

# Supervisor
ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

ADD docker/start.sh /usr/local/bin/start

# Create homestead user
RUN useradd homestead \
    && useradd vuejs

# Create root directory and home directory
RUN mkdir -p /srv/app \
    && mkdir -p /home/vuejs \
    && cp -R ~/. /home/vuejs/
RUN chown -R vuejs:vuejs /srv/app \
    && chown -R vuejs:vuejs /home/vuejs \
    && chmod 777 /usr/local/bin/start

ARG USER_ID
ARG GROUP_ID

RUN if $(id -un ${USER_ID} >/dev/null 2>&1); then \
        userdel -f $(id -un ${USER_ID}); \
        if $(id -un vuejs >/dev/null 2>&1); then \
            usermod -u ${USER_ID} vuejs; \
        else \
            useradd -u ${USER_ID} vuejs; \
        fi \
    else \
        if $(id -un vuejs >/dev/null 2>&1); then \
            usermod -u ${USER_ID} vuejs; \
        else \
            useradd -u ${USER_ID} vuejs; \
        fi \
    fi \
    && \
    if [ $(getent group ${GROUP_ID}) ]; then \
        groupdel -f $(getent group ${GROUP_ID} | cut -d: -f1); \
        if [ $(getent group vuejs) ]; then \
            groupmod -g ${GROUP_ID} -n vuejs vuejs; \
        else \
            groupadd -g ${GROUP_ID} vuejs; \
        fi \
    else \
        if [ $(getent group vuejs) ]; then \
            groupmod -g ${GROUP_ID} -n vuejs vuejs; \
        else \
            groupadd -g ${GROUP_ID} vuejs; \
        fi \
    fi \
    && \
    chown vuejs:vuejs -R /srv/app \
    && \
    chown vuejs:vuejs -R /etc/supervisor

RUN echo 'vuejs:Docker!' | chpasswd \
    && usermod -a -G sudo vuejs \
    && echo 'vuejs    ALL=(ALL:ALL) ALL' >> /etc/sudoers

USER vuejs

CMD ["/usr/local/bin/start"]
