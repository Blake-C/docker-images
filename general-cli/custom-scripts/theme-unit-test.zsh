#!/bin/zsh

SERVER_DIR='/var/www/public_html'
DATABASE_BACKUPS='/var/www/data/backups'

alias root="cd $SERVER_DIR"
alias theme="cd $SERVER_DIR/wp-content/themes/wp-foundation-six"
alias theme_components="cd $SERVER_DIR/wp-content/themes/wp-foundation-six/theme_components"

theme-unit-test() {
	WORKING_DIR=$(pwd);

	cd $SERVER_DIR
	curl https://wpcom-themes.svn.automattic.com/demo/theme-unit-test-data.xml >> theme-unit-test-data.xml
	wp plugin install wordpress-importer --activate --allow-root
	wp import theme-unit-test-data.xml --authors=create --allow-root
	rm theme-unit-test-data.xml
	cd $WORKING_DIR
}
