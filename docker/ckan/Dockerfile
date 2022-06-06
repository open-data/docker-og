FROM openknowledge/ckan-base:2.8
FROM php:7.4-fpm

USER root

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

RUN if [ ! $(id -un ${USER_ID}) == "ckan" ]; then \
        userdel -f $(id -un ${USER_ID}); \
        usermod -u ${USER_ID} ckan; \
    else \
        usermod -u ${USER_ID} ckan; \
    fi \
    && \
    if [ ! $(id -gn ${GROUP_ID}) == "ckan" ]; then \
        groudel -f $(id -gn ${GROUP_ID}); \
        groupmod -g ${GROUP_ID} -n ckan ckan; \
    else \
        groupmod -g ${GROUP_ID} -n ckan ckan; \
    fi \
    && \
    chown ckan:ckan -R /srv/app

CMD ["/usr/local/bin/start"]