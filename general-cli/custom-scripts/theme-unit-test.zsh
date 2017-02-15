#!/bin/zsh

SERVER_DIR='/var/www/public_html'
theme-unit-test() {
	WORKING_DIR=$(pwd);

	cd $SERVER_DIR
	curl https://wpcom-themes.svn.automattic.com/demo/theme-unit-test-data.xml >> theme-unit-test-data.xml
	wp plugin install wordpress-importer --activate --allow-root
	wp import theme-unit-test-data.xml --authors=create --allow-root
	rm theme-unit-test-data.xml
	cd $WORKING_DIR
}
