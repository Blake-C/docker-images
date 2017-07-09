FROM ubuntu:16.04
MAINTAINER Blake Cerecero <blake@digitalblake.com

# PHP
RUN apt-get update -y \
	&& apt-get install curl -y \
	&& apt-get install wget -y \
	&& apt-get install php7.0 -y \
	&& apt-get install zip -y \
	&& apt-get install mysql-client -y \
	&& apt-get install php-mysql -y

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install WP-CLI
RUN apt-get update -y \
	&& curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar \
	&& mv wp-cli.phar /usr/local/bin/wp

# Neovim
RUN	apt-get update -y \
	&& apt-get install software-properties-common -y \
	&& add-apt-repository ppa:neovim-ppa/stable -y \
	&& apt-get update -y \
	&& apt-get install neovim -y \
	&& apt-get install python-dev python-pip python3-dev python3-pip -y \
	&& update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60

# Other CLIs
RUN apt-get update -y \
	&& apt-get install nano -y \
	&& apt-get install git -y \
	&& curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash \
	&& export NVM_DIR="$HOME/.nvm" \
	&& [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
	&& [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
	&& nvm install node \
	&& nvm install v6.11.0 \
	&& nvm alias default v6.11.0 \
	&& npm install yarn -g \
	&& npm install gulp -g \
	&& npm install grunt -g \
	&& npm install bower -g \
	&& npm install eslint -g \
	&& npm install sass-lint -g

# ZSH
RUN apt-get update -y \
	&& apt-get install zsh -y \
	&& bash -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
	&& sed -i '/plugins=(git)/c\plugins=(git bower npm composer gulp wp-cli extract yarn redis-cli)' ~/.zshrc \
	&& sed -i '/\# ZSH_CUSTOM=\/path\/to\/new-custom-folder/c\ZSH_CUSTOM=~/custom-scripts' ~/.zshrc


COPY custom-scripts/global-scripts.zsh /root/custom-scripts/global-scripts.zsh
COPY custom-scripts/setup-scripts.zsh /root/custom-scripts/setup-scripts.zsh

# Misc.
RUN apt-get --purge autoremove -y

WORKDIR /var/www/public_html
