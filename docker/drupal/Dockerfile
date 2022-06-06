FROM php:7.4-fpm

USER root

ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_OPCACHE_MAX_ACCELERATED_FILES=9000 \
    PHP_OPCACHE_MEMORY_CONSUMPTION=128

RUN docker-php-source extract \
    && apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
        nginx \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        supervisor \
        procps \
        libpng-dev \
		git \
		libzip-dev \
        zip \
        unzip \
        libjpeg-dev \
        graphviz \
        libicu-dev \
        jpegoptim \
        optipng \
        pngquant \
        gifsicle \
        libfreetype6-dev \
        wget \
        less \
        postgresql \
        libpq-dev \
        curl \
        nano \
        vim \
        memcached \
        libmemcached-tools \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install sockets pdo pdo_pgsql pgsql gd zip exif bcmath intl pcntl \
    && pecl install xdebug \
    && pecl install redis \
    && docker-php-ext-enable sockets xdebug opcache redis pdo_pgsql pgsql \
    && docker-php-source delete

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/ \
        && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# PHP
ADD docker/config/php/conf.d/*.ini /usr/local/etc/php/conf.d/
ADD docker/config/php/php.ini /usr/local/etc/php/php.ini
ADD docker/config/php/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

# Supervisor
ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

# Nginx
ADD docker/config/nginx/nginx.conf /etc/nginx/nginx.conf
ADD docker/config/nginx/open.local /etc/nginx/sites-available/open.local
ADD docker/config/nginx/h5bp/ /etc/nginx/h5bp

ADD docker/start.sh /usr/local/bin/start

# Create homestead user
RUN useradd homestead

# Create root directory
RUN mkdir -p /var/www/html
RUN chown -R www-data:www-data /var/www/html \
    && chmod +x /usr/local/bin/start \
    && chmod +w /usr/local/var/run \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log


ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
        if [ $(getent passwd | grep www-data) ]; then \
            userdel -f www-data; fi && \
        if [ $(getent group | grep ${GROUP_ID}) ]; then \
            groupmod -g ${GROUP_ID} -n www-data $(getent group ${GROUP_ID} | cut -d: -f1); else \
            groupadd -g ${GROUP_ID} www-data; fi && \
        if [ $(getent passwd | grep ${USER_ID}) ]; then \
            usermod -l www-data -g www-data $(getent passwd ${USER_ID} | cut -d: -f1); else \
            useradd -l -u ${USER_ID} -g www-data www-data; fi && \
        install -d -m 0755 -o www-data -g www-data /home/www-data && \
        chown --changes --silent --no-dereference --recursive --from=33:33 ${USER_ID}:${GROUP_ID} /home/www-data && \
        echo 'alias ls="ls $LS_OPTIONS"\n\
        alias ll="ls $LS_OPTIONS -l"\n\
        alias l="ls $LS_OPTIONS -lA"\n\
        alias phpunit="vendor/bin/phpunit"\n\
        alias home="cd /var/www/html"\n\
        alias mrs="artisan migrate:refresh --seed"\n\
        function artisan() {\n\
        php artisan "$@"\n\
        }' >> /home/www-data/.bashrc &&\
        chown www-data:www-data /home/www-data/.bashrc \
;fi

CMD ["/usr/local/bin/start"]
