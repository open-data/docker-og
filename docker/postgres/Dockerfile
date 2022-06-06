FROM postgres:13.5

ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
        if [ $(getent passwd | grep postgres) ]; then \
            userdel -f postgres; fi &&\
        if [ $(getent group | grep ${GROUP_ID}) ]; then \
            groupmod -g ${GROUP_ID} -n postgres $(getent group ${GROUP_ID} | cut -d: -f1); else \
            groupadd -g ${GROUP_ID} postgres; fi &&\
        if [ $(getent passwd | grep ${USER_ID}) ]; then \
            usermod -l postgres -g postgres $(getent passwd ${USER_ID} | cut -d: -f1); else \
            useradd -l -u ${USER_ID} -g postgres postgres; fi && \
        install -d -m 0755 -o postgres -g postgres /var/lib/postgresql && \
        chown --changes --silent --no-dereference --recursive --from=33:33 ${USER_ID}:${GROUP_ID} /var/lib/postgresql && \
        echo 'alias ls="ls $LS_OPTIONS"\n\
        alias ll="ls $LS_OPTIONS -l"\n\
        alias l="ls $LS_OPTIONS -lA"\n\
        alias home="cd /var/lib/postgresql"' >> /var/lib/postgresql/.bashrc &&\
        chown postgres:postgres /var/lib/postgresql/.bashrc \
;fi

RUN chown postgres:postgres -R /var/lib/postgresql