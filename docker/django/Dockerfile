FROM python:3.7.13

USER root

RUN echo 'root:Docker!' | chpasswd

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
        python3-dev \
        python3-venv \
        postgresql \
        curl \
        tar \
        wget \
        build-essential \
        nano \
        vim \
        redis-server \
        sudo \
        systemd \
        sysvinit-utils \
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
    && chmod 777 /usr/local/bin/start

ARG USER_ID
ARG GROUP_ID

RUN if $(id -un ${USER_ID} >/dev/null 2>&1); then \
        userdel -f $(id -un ${USER_ID}); \
        if $(id -un django >/dev/null 2>&1); then \
            usermod -u ${USER_ID} django; \
        else \
            useradd -u ${USER_ID} django; \
        fi \
    else \
        if $(id -un django >/dev/null 2>&1); then \
            usermod -u ${USER_ID} django; \
        else \
            useradd -u ${USER_ID} django; \
        fi \
    fi \
    && \
    if [ $(getent group ${GROUP_ID}) ]; then \
        groupdel -f $(getent group ${GROUP_ID} | cut -d: -f1); \
        if [ $(getent group django) ]; then \
            groupmod -g ${GROUP_ID} -n django django; \
        else \
            groupadd -g ${GROUP_ID} django; \
        fi \
    else \
        if [ $(getent group django) ]; then \
            groupmod -g ${GROUP_ID} -n django django; \
        else \
            groupadd -g ${GROUP_ID} django; \
        fi \
    fi \
    && \
    chown django:django -R /var/ocs \
    && \
    chown django:django -R /etc/supervisor

RUN echo 'django:Docker!' | chpasswd \
    && usermod -a -G sudo django \
    && echo 'django    ALL=(ALL:ALL) ALL' >> /etc/sudoers

USER django

CMD ["/usr/local/bin/start"]
