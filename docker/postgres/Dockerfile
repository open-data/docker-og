FROM postgres:13.5

USER root

ARG USER_ID
ARG GROUP_ID

RUN if [ $(id -un ${USER_ID}) ]; then \
        userdel -f $(id -un ${USER_ID}); \
        if [ $(id -un postgres) ]; then \
            usermod -u ${USER_ID} postgres; \
        else \
            useradd -u ${USER_ID} postgres; \
        fi \
    else \
        if [ $(id -un postgres) ]; then \
            usermod -u ${USER_ID} postgres; \
        else \
            useradd -u ${USER_ID} postgres; \
        fi \
    fi \
    && \
    if [ $(id -gn ${GROUP_ID}) ]; then \
        groupdel -f $(id -gn ${GROUP_ID}); \
        if [ $(getent group postgres) ]; then \
            groupmod -g ${GROUP_ID} -n postgres postgres; \
        else \
            groupadd -g ${GROUP_ID} postgres; \
        fi \
    else \
        if [ $(getent group postgres) ]; then \
            groupmod -g ${GROUP_ID} -n postgres postgres; \
        else \
            groupadd -g ${GROUP_ID} postgres; \
        fi \
    fi \
    && \
    chown postgres:postgres -R /var/lib/postgresql