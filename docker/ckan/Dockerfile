FROM openknowledge/ckan-base:2.8
FROM ubuntu

USER root

RUN echo 'root:Docker!' | chpasswd

RUN apt-get update -yqq \
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y --no-install-recommends \
        nodejs \
        supervisor \
		git \
		libzip-dev \
        zip \
        unzip \
        wget \
        python2-dev \
        postgresql \
        libpq-dev \
        libpcre3 \
        libpcre3-dev \
        virtualenv \
        redis-server \
        curl \
        nano \
        vim \
        sudo \
        systemd \
        sysvinit-utils \
    && npm install -g less \
    && npm install less \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql zip \
    && docker-php-ext-enable pdo_pgsql pgsql

# Supervisor
ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

# PIP2
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py \
    && python2 get-pip.py

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