FROM openknowledge/ckan-base:2.9
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
    && npm install -g less \
    && npm install less \
    && wget https://www.python.org/ftp/python/3.9.7/Python-3.9.7.tgz \
    && tar -xf Python-3.9.7.tgz \
    && cd Python-3.9.7 \
    && ./configure --enable-shared \
    && make -j 8 \
    && sudo make altinstall \
    && sudo ldconfig /usr/local/bin/python3.9 \
    && sudo update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 1 \
    && sudo update-alternatives --config python3 \
    && sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.9 1 \
    && sudo update-alternatives --config python
# note: --enable-optimizations in the configure python
# runs many tests which slows the build down a lot.
# if python3.9.7 is not working, add it and re-run the build.

# Supervisor
ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

# PIP 3.9
RUN curl https://bootstrap.pypa.io/get-pip.py | sudo python3.9

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
