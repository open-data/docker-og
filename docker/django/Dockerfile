FROM python:3.7.13

USER root

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
        supervisor \
        procps \
		git \
		libzip-dev \
        zip \
        unzip \
        wget \
        less \
        postgresql \
        curl \
        tar \
        wget \
        build-essential \
        nano \
        vim \
        redis-server \
    && cd /usr/bin \
    && wget -c http://www.sqlite.org/2020/sqlite-autoconf-3330000.tar.gz \
    && tar -xvf sqlite-autoconf-3330000.tar.gz \
    && cd sqlite-autoconf-3330000 \
    && ./configure \
    && make \
    && make install

# Supervisor
ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

ADD docker/start.sh /usr/local/bin/start

# Create homestead user
RUN useradd homestead \
    && useradd django

# Create root directory
RUN mkdir -p /var/ocs
RUN chown -R django:django /var/ocs \
    && chmod +x /usr/local/bin/start

ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
        if [ $(getent passwd | grep django) ]; then \
            userdel -f django; fi && \
        if [ $(getent group | grep ${GROUP_ID}) ]; then \
            groupmod -g ${GROUP_ID} -n django $(getent group ${GROUP_ID} | cut -d: -f1); else \
            groupadd -g ${GROUP_ID} django; fi && \
        if [ $(getent passwd | grep ${USER_ID}) ]; then \
            usermod -l django -g django $(getent passwd ${USER_ID} | cut -d: -f1); else \
            useradd -l -u ${USER_ID} -g django django; fi && \
        install -d -m 0755 -o django -g django /home/django && \
        chown --changes --silent --no-dereference --recursive --from=33:33 ${USER_ID}:${GROUP_ID} /home/django && \
        echo 'alias ls="ls $LS_OPTIONS"\n\
        alias ll="ls $LS_OPTIONS -l"\n\
        alias l="ls $LS_OPTIONS -lA"\n\
        alias phpunit="vendor/bin/phpunit"\n\
        alias home="cd /var/www/html"\n\
        alias mrs="artisan migrate:refresh --seed"\n\
        function artisan() {\n\
        php artisan "$@"\n\
        }' >> /home/django/.bashrc &&\
        chown django:django /home/django/.bashrc \
;fi

CMD ["/usr/local/bin/start"]
