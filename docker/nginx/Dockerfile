FROM nginx

USER root

RUN echo 'root:Docker!' | chpasswd

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
        nginx \
        iputils-ping \
        sudo \
        systemd \
        sysvinit-utils \
        supervisor

# Supervisor
ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

# Nginx
ADD docker/config/nginx/nginx.conf /etc/nginx/nginx.conf

ADD docker/config/nginx/proxied_sites/open.local /etc/nginx/sites-available/open.local
ADD docker/config/nginx/proxied_sites/portal.open.local /etc/nginx/sites-available/portal.open.local
ADD docker/config/nginx/proxied_sites/registry.open.local /etc/nginx/sites-available/registry.open.local
ADD docker/config/nginx/proxied_sites/registre.ouvert.local /etc/nginx/sites-available/registre.ouvert.local
ADD docker/config/nginx/proxied_sites/search.open.local /etc/nginx/sites-available/search.open.local
ADD docker/config/nginx/proxied_sites/solr.open.local /etc/nginx/sites-available/solr.open.local

ADD docker/config/nginx/h5bp/ /etc/nginx/h5bp

ADD docker/start.sh /usr/local/bin/start

# Set files and directories permsissions and ownerships
RUN chmod 777 /usr/local/bin/start \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ARG USER_ID
ARG GROUP_ID

RUN if $(id -un ${USER_ID} >/dev/null 2>&1); then \
        userdel -f $(id -un ${USER_ID}); \
        if $(id -un www-data >/dev/null 2>&1); then \
            usermod -u ${USER_ID} www-data; \
        else \
            useradd -u ${USER_ID} www-data; \
        fi \
    else \
        if $(id -un www-data >/dev/null 2>&1); then \
            usermod -u ${USER_ID} www-data; \
        else \
            useradd -u ${USER_ID} www-data; \
        fi \
    fi \
    && \
    if [ $(getent group ${GROUP_ID}) ]; then \
        groupdel -f $(getent group ${GROUP_ID} | cut -d: -f1); \
        if [ $(getent group www-data) ]; then \
            groupmod -g ${GROUP_ID} -n www-data www-data; \
        else \
            groupadd -g ${GROUP_ID} www-data; \
        fi \
    else \
        if [ $(getent group www-data) ]; then \
            groupmod -g ${GROUP_ID} -n www-data www-data; \
        else \
            groupadd -g ${GROUP_ID} www-data; \
        fi \
    fi \
    && \
    chown www-data:www-data -R /etc/nginx \
    && \
    mkdir -p /var/ogproxy \
    && \
    chown www-data:www-data -R /var/ogproxy \
    && \
    chown www-data:www-data -R /etc/supervisor

RUN echo 'www-data:Docker!' | chpasswd \
    && usermod -a -G sudo www-data \
    && echo 'www-data    ALL=(ALL:ALL) ALL' >> /etc/sudoers

USER www-data

CMD ["/usr/local/bin/start"]