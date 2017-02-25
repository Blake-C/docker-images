FROM php:7.0.6-fpm-alpine
MAINTAINER Blake Cerecero <blake@digitalblake.com>

# We need these system-level scritps to run WordPress successfully
RUN apk add --no-cache mysql-client curl \
    imagemagick-dev

# As per image documentation, this is how we install PHP modules
RUN docker-php-ext-install -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    iconv gd mbstring fileinfo curl xmlreader xmlwriter spl ftp mysqli opcache

# Install imagemagick for PHP
RUN apk add --no-cache libtool build-base autoconf \
    && pecl install imagick \
    && docker-php-ext-enable imagick

RUN apk update && apk add --no-cache --virtual .build-deps autoconf gcc make wget \
    g++ zlib-dev file g++ libc-dev make pkgconf \
    tar curl php-pear tzdata php-dev php-phar libmemcached-dev \
    && apk add php php-cli php-curl php-gd git php-json libmemcached \

    # Xdebug
    && cd /tmp && wget http://xdebug.org/files/xdebug-2.5.0.tgz \
    && tar -zxvf xdebug-2.5.0.tgz \
    && cd xdebug-2.5.0 && phpize \
    && ./configure --enable-xdebug && make && make install \

    # Cleanup
    && apk del libtool build-base autoconf \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    && apk del .build-deps && rm -rf tmp/*

# Copy xdebug configration for remote debugging
COPY ./php.ini /usr/local/etc/php/php.ini

WORKDIR /var/www/public_html
