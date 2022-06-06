FROM nginx

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
        nginx \
        supervisor

# Supervisor
ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

# Nginx
ADD docker/config/nginx/nginx.conf /etc/nginx/nginx.conf

ADD docker/config/nginx/proxied_sites/open.local /etc/nginx/sites-available/open.local
ADD docker/config/nginx/proxied_sites/portal.open.local /etc/nginx/sites-available/portal.open.local
ADD docker/config/nginx/proxied_sites/registry.open.local /etc/nginx/sites-available/registry.open.local
ADD docker/config/nginx/proxied_sites/search.open.local /etc/nginx/sites-available/search.open.local
ADD docker/config/nginx/proxied_sites/solr.open.local /etc/nginx/sites-available/solr.open.local

ADD docker/config/nginx/h5bp/ /etc/nginx/h5bp

ADD docker/start.sh /usr/local/bin/start

# Set files and directories permsissions and ownerships
RUN chmod +x /usr/local/bin/start \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
        if [ $(getent passwd | grep www-data) ]; then \
            userdel -f www-data; fi &&\
        if [ $(getent group | grep ${GROUP_ID}) ]; then \
            groupmod -g ${GROUP_ID} -n www-data $(getent group ${GROUP_ID} | cut -d: -f1); else \
            groupadd -g ${GROUP_ID} www-data; fi &&\
        if [ $(getent passwd | grep ${USER_ID}) ]; then \
            usermod -l www-data -g www-data $(getent passwd ${USER_ID} | cut -d: -f1); else \
            useradd -l -u ${USER_ID} -g www-data www-data; fi && \
        install -d -m 0755 -o www-data -g www-data /etc/nginx && \
        chown --changes --silent --no-dereference --recursive --from=33:33 ${USER_ID}:${GROUP_ID} /etc/nginx && \
        echo 'alias ls="ls $LS_OPTIONS"\n\
        alias ll="ls $LS_OPTIONS -l"\n\
        alias l="ls $LS_OPTIONS -lA"\n\
        alias home="cd /etc/nginx"' >> /etc/nginx/.bashrc &&\
        chown www-data:www-data /etc/nginx/.bashrc \
;fi


RUN chown www-data:www-data -R /etc/nginx

CMD ["/usr/local/bin/start"]