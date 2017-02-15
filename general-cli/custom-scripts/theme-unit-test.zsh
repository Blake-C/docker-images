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

wp-db-export() {
	echo "\n================================================================="
	echo "Export WordPress database"
	echo "================================================================="

	echo "\nLeave this blank if you do not want to change the site url"
	vared -p "Production URL: " -c REPLACEURL

	WORKING_DIR=$(pwd);
	cd $SERVER_DIR

	if [[ "$REPLACEURL" ]]; then
		wp search-replace "0.0.0.0:8080" "$REPLACEURL" --allow-root
	fi

	wp db export $DATABASE_BACKUPS/wp_foundation_six_$(date +"%Y%m%d%H%M%s")_database.sql --allow-root
	cd $WORKING_DIR

	if [[ "$REPLACEURL" != "" ]]; then
		wp search-replace "$REPLACEURL" "0.0.0.0:8080" --allow-root
	fi

	echo "\n"
}
