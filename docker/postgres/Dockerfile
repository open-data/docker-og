FROM postgres:13.5

USER root

ARG USER_ID
ARG GROUP_ID

RUN usermod -u ${USER_ID} postgres \
    && groupmod -g ${GROUP_ID} -n postgres postgres \
    && chown postgres:postgres -R /var/lib/postgresql