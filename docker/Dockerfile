FROM php:7.4-fpm

ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    PHP_OPCACHE_MAX_ACCELERATED_FILES=9000 \
    PHP_OPCACHE_MEMORY_CONSUMPTION=128

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
        nginx \
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
        nano \
        vim \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql gd zip exif bcmath intl pcntl \
    && pecl install xdebug \
    && pecl install redis \
    && docker-php-ext-enable xdebug opcache redis pdo_pgsql pgsql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/ \
        && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        && chmod +x wp-cli.phar \
        && mv wp-cli.phar /usr/local/bin/wp

# PHP
ADD docker/config/php/conf.d/*.ini /usr/local/etc/php/conf.d/
ADD docker/config/php/php.ini /usr/local/etc/php/php.ini
ADD docker/config/php/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

# Supervisor
ADD docker/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD docker/config/supervisor/conf.d/*.conf /etc/supervisor/conf.d-available/

# Nginx
ADD docker/config/nginx/default /etc/nginx/sites-available/default
ADD docker/config/nginx/mailhog /etc/nginx/sites-available/mailhog
ADD docker/config/nginx/h5bp/ /etc/nginx/h5bp

ADD docker/start.sh /usr/local/bin/start

# Create homestead user
RUN useradd homestead

RUN chown -R www-data:www-data /var/www/html \
    && chmod +x /usr/local/bin/start \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    userdel -f www-data &&\
    if getent group www-data ; then groupdel www-data; fi &&\
    groupadd -g ${GROUP_ID} www-data &&\
    useradd -l -u ${USER_ID} -g www-data www-data &&\
    install -d -m 0755 -o www-data -g www-data /home/www-data &&\
    chown --changes --silent --no-dereference --recursive \
          --from=33:33 ${USER_ID}:${GROUP_ID} \
        /home/www-data &&\
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
