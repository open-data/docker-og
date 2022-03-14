FROM openknowledge/ckan-base:2.8
FROM php:7.4-fpm

RUN apt-get update -yqq \
    curl -sL https://deb.nodesource.com/setup_12.x | bash - \
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
    && chmod +x /usr/local/bin/start

ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
        if [ $(getent passwd | grep ckan) ]; then \
            userdel -f ckan; fi &&\
        if [ $(getent group | grep ${GROUP_ID}) ]; then \
            groupmod -g ${GROUP_ID} -n ckan $(getent group ${GROUP_ID} | cut -d: -f1); else \
            groupadd -g ${GROUP_ID} ckan; fi &&\
        if [ $(getent passwd | grep ${USER_ID}) ]; then \
            usermod -l ckan -g ckan $(getent passwd ${USER_ID} | cut -d: -f1); else \
            useradd -l -u ${USER_ID} -g ckan ckan; fi && \
        install -d -m 0755 -o ckan -g ckan /srv/app && \
        chown --changes --silent --no-dereference --recursive --from=33:33 ${USER_ID}:${GROUP_ID} /srv/app && \
        echo 'alias ls="ls $LS_OPTIONS"\n\
        alias ll="ls $LS_OPTIONS -l"\n\
        alias l="ls $LS_OPTIONS -lA"\n\
        alias home="cd /srv/app"' >> /srv/app/.bashrc &&\
        chown ckan:ckan /srv/app/.bashrc \
;fi

RUN chown ckan:ckan -R /srv/app

CMD ["/usr/local/bin/start"]