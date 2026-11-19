FROM ckan/ckan-dev:2.10
FROM debian:bookworm

USER root

RUN echo 'root:Docker!' | chpasswd

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONUTF8=1

WORKDIR /srv/app

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
        curl \
    && apt purge -y nodejs \
    && apt autoremove -y \
    && apt-get install -y --no-install-recommends \
        nodejs \
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
    && curl --insecure -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | GIT_SSL_NO_VERIFY=1 bash \
    && . ~/.bashrc \
    && NVM_NODEJS_ORG_MIRROR=http://nodejs.org/dist nvm install 16 \
    && nvm use 16 \
    && npm install -g less \
    && npm install less \
    && wget https://www.python.org/ftp/python/3.9.25/Python-3.9.25.tgz \
    && tar -xf Python-3.9.25.tgz \
    && cd Python-3.9.25 \
    && ./configure --enable-shared --enable-optimizations \
    && make -j 10 \
    && make altinstall \
    && ldconfig /usr/local/bin/python3.9 \
    && cd / \
    && rm -rf Python-3.9.25 Python-3.9.25.tgz \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.9 1 \
    && sudo update-alternatives --config python3 \
    && sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.9 1 \
    && sudo update-alternatives --config python
# note: --enable-optimizations in the configure python
# runs many tests which slows the build down a lot.
# if python is not working, add it and re-run the build.

# Supervisor
ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

# PIP 3.9
RUN curl https://bootstrap.pypa.io/get-pip.py | sudo python3.9
RUN pip install supervisor

ADD docker/start.sh /usr/local/bin/start

# Create ckan user
RUN useradd ckan

# Create root directory and home directory
RUN mkdir -p /srv/app \
    && mkdir -p /home/ckan \
    && cp -R ~/. /home/ckan/
RUN chown -R ckan:ckan /srv/app \
    && chown -R ckan:ckan /home/ckan \
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
