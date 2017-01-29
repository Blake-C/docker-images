FROM php:7.0.6-fpm-alpine
MAINTAINER Blake Cerecero <blake@digitalblake.com>

# We need these system-level scritps to run WordPress successfully
RUN apk add --no-cache nginx mysql-client supervisor curl \
    bash redis imagemagick-dev

# As per image documentation, this is how we install PHP modules
RUN docker-php-ext-install -j$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    iconv gd mbstring fileinfo curl xmlreader xmlwriter spl ftp mysqli opcache

# Install imagemagick for PHP
RUN apk add --no-cache libtool build-base autoconf \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apk del libtool build-base autoconf

# Create a user called "deployer" without a password and belonging
# to the same group as php-fpm and nginx belong to
RUN adduser -D deployer -s /bin/bash -G www-data

# Install WP-CLI (for convenience)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy over our custom Nginx configuration and log to stderr/stdout
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/virtual-host.conf /etc/nginx/conf.d/
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && chown -R www-data:www-data /var/lib/nginx

# Copy supervisor configuration for both processes
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisord.conf

# Copy and prepare the entrypoint
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]

RUN apk update \
     && apk add nano \
     && apk add git \
     && apk add zsh \
     && apk add nodejs \
     && npm install yarn -g \
     && npm install gulp -g \
     && bash -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
     && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
     && echo 'alias ll="ls -lagh"' >> ~/.zshrc \
     && echo 'alias wp="wp --allow-root"' >> ~/.zshrc \
     && sed -i '/plugins=(git)/c\plugins=(git bower npm composer gulp wp-cli extract)' ~/.zshrc \
     && rm -rf /var/www/html

WORKDIR /var/www/public_html
