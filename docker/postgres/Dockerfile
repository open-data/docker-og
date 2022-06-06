FROM postgres:13.5

USER root

ARG USER_ID
ARG GROUP_ID

RUN if [ "$(id -un $USER_ID)" != "postgres" ]; then \
        userdel -f $(id -un ${USER_ID}); \
        usermod -u ${USER_ID} postgres; \
    else \
        usermod -u ${USER_ID} postgres; \
    fi \
    && \
    if [ "$(id -gn $GROUP_ID)" != "postgres" ]; then \
        groudel -f $(id -gn ${GROUP_ID}); \
        groupmod -g ${GROUP_ID} -n postgres postgres; \
    else \
        groupmod -g ${GROUP_ID} -n postgres postgres; \
    fi \
    && \
    chown postgres:postgres -R /var/lib/postgresql