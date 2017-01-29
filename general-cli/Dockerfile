FROM ubuntu:16.04
MAINTAINER Blake Cerecero <blake@digitalblake.com

# PHP
RUN apt-get update -y \
    && apt-get install curl -y \
    && apt-get install php7.0 -y \
    && apt-get install zip -y \
    && apt-get install mysql-client -y \
    && apt-get install php-mysql -y

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install WP-CLI 
RUN apt-get update -y \
    && apt-get install curl -y \
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Other CLIs
RUN apt-get update -y \
    && apt-get install nano -y \
    && apt-get install vim -y \
    && apt-get install git -y \
    && curl -sL https://deb.nodesource.com/setup_7.x | bash - \
    && apt-get install nodejs -y \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install yarn \
    && npm install gulp -g \
    && npm install bower -g

# ZSH
RUN apt-get install zsh -y \
    && bash -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
    && echo 'alias ll="ls -lagh"' >> ~/.zshrc \
    && echo 'alias wp="wp --allow-root"' >> ~/.zshrc \
    && sed -i '/plugins=(git)/c\plugins=(git bower npm composer gulp wp-cli extract yarn redis-cli)' ~/.zshrc \
    && sed -i '/\# ZSH_CUSTOM=\/path\/to\/new-custom-folder/c\ZSH_CUSTOM=~/custom-scripts' ~/.zshrc

COPY custom-scripts/theme-unit-test.zsh /root/custom-scripts/theme-unit-test.zsh

# Misc.
RUN apt-get --purge autoremove -y

WORKDIR /var/www/public_html