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

RUN if [[ ! $(id -un ${USER_ID}) == "django" ]]; then \
        userdel -f $(id -un ${USER_ID}); \
        usermod -u ${USER_ID} django; \
    else \
        usermod -u ${USER_ID} django; \
    fi \
    && \
    if [[ ! $(id -gn ${GROUP_ID}) == "django" ]]; then \
        groudel -f $(id -gn ${GROUP_ID}); \
        groupmod -g ${GROUP_ID} -n django django; \
    else \
        groupmod -g ${GROUP_ID} -n django django; \
    fi \
    && \
    chown django:django -R /var/ocs

CMD ["/usr/local/bin/start"]
