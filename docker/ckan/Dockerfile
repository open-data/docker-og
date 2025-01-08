FROM ckan/ckan-dev:2.10
FROM debian:bullseye-slim

USER root

RUN echo 'root:Docker!' | chpasswd

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /srv/app

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
        curl \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y --no-install-recommends \
        nodejs \
        npm \
        gcc \
        supervisor \
        build-essential \
		git \
		libzip-dev \
        zip \
        unzip \
        wget \
        postgresql \
        libpq-dev \
        libpcre3 \
        libpcre3-dev \
        libmagic-dev \
        redis-server \
        nano \
        vim \
        sudo \
        systemd \
        sysvinit-utils \
        build-essential \
        zlib1g-dev \
        libncurses5-dev \
        libgdbm-dev \
        libnss3-dev \
        libssl-dev \
        libsqlite3-dev \
        libreadline-dev \
        libffi-dev \
        libbz2-dev \
        python3-dev \
        python3-venv \
        python3-pip \
    && npm install -g less \
    && npm install less
# note: --enable-optimizations in the configure python
# runs many tests which slows the build down a lot.
# if python is not working, add it and re-run the build.

# Supervisor
ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

ADD docker/start.sh /usr/local/bin/start

# Create ckan user
RUN useradd ckan

# Create root directory
RUN mkdir -p /srv/app \
    && mkdir -p /etc/ckan
RUN chown -R ckan:ckan /srv/app \
    && chown -R ckan:ckan /etc/ckan \
    && chmod 777 /usr/local/bin/start

ARG USER_ID
ARG GROUP_ID

RUN if $(id -un ${USER_ID} >/dev/null 2>&1); then \
        userdel -f $(id -un ${USER_ID}); \
        if $(id -un ckan >/dev/null 2>&1); then \
            usermod -u ${USER_ID} ckan; \
        else \
            useradd -u ${USER_ID} ckan; \
        fi \
    else \
        if $(id -un ckan >/dev/null 2>&1); then \
            usermod -u ${USER_ID} ckan; \
        else \
            useradd -u ${USER_ID} ckan; \
        fi \
    fi \
    && \
    if [ $(getent group ${GROUP_ID}) ]; then \
        groupdel -f $(getent group ${GROUP_ID} | cut -d: -f1); \
        if [ $(getent group ckan) ]; then \
            groupmod -g ${GROUP_ID} -n ckan ckan; \
        else \
            groupadd -g ${GROUP_ID} ckan; \
        fi \
    else \
        if [ $(getent group ckan) ]; then \
            groupmod -g ${GROUP_ID} -n ckan ckan; \
        else \
            groupadd -g ${GROUP_ID} ckan; \
        fi \
    fi \
    && \
    chown ckan:ckan -R /srv/app \
    && \
    chown ckan:ckan -R /etc/supervisor

RUN echo 'ckan:Docker!' | chpasswd \
    && usermod -a -G sudo ckan \
    && echo 'ckan    ALL=(ALL:ALL) ALL' >> /etc/sudoers

USER ckan

CMD ["/usr/local/bin/start"]
