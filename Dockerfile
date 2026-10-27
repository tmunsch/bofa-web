# BofaNodes web image: nginx + PHP-FPM for the WordPress, WP infinite, Drupal and other PHP eggs.
#
# Built on the official PHP image (security fixes land there first), with OPcache and the
# extensions WordPress, Drupal, Laravel and most PHP apps want. The egg ships its own nginx and
# PHP-FPM config in the server's folder; this image only provides the programs.
#
# Build one image per PHP version:  docker build --build-arg PHP_VERSION=8.3 -t bofanodes-web:8.3 .

ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm-alpine

# tools the start script, App Setup's setup scripts and users' console commands use
RUN apk upgrade --no-cache \
    && apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        git \
        mariadb-client \
        nginx \
        tar \
        tzdata \
        unzip \
        zip

# PHP extensions (the official image already has ctype, curl, dom, fileinfo, iconv, mbstring,
# openssl, pdo_sqlite, phar, session, simplexml, sodium, tokenizer, xml and zlib)
COPY --from=mlocati/php-extension-installer:2 /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
        apcu \
        bcmath \
        bz2 \
        calendar \
        exif \
        gd \
        gmp \
        igbinary \
        imagick \
        intl \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        redis \
        soap \
        sockets \
        xsl \
        zip \
    && rm /usr/local/bin/install-php-extensions

# Composer and WP-CLI
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# PHP settings: production defaults, OPcache tuned for sites whose files change (plugin updates)
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY php/bofanodes.ini "$PHP_INI_DIR/conf.d/90-bofanodes.ini"
COPY php/opcache.ini "$PHP_INI_DIR/conf.d/90-bofanodes-opcache.ini"

# Per-server PHP settings: any .ini file in the server's php-fpm/conf.d folder is read after the
# image's own (the leading ":" keeps PHP's default folder)
ENV PHP_INI_SCAN_DIR=":/home/container/php-fpm/conf.d"

# Wings runs the container as its own user; the image needs a home for it
RUN adduser -D -h /home/container container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY --chmod=755 entrypoint.sh /entrypoint.sh
CMD ["/bin/bash", "/entrypoint.sh"]
