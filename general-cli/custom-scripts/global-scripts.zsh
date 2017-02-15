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
	echo "Export WordPress Database"
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

wp-init() {
	root

	echo "\nRunning Composer"
	composer install
	composer update

    if ! $(wp core is-installed); then
		echo "\n\n"

		local PASSWORD
		local WPUSER
		local WP_ADMIN_MAIL

		# Accept user input for the databse name
		vared -p "Wordpress User: " -c WPUSER

		# Accept user input for the databse name
		vared -p "Wordpress User Email Address: " -c WP_ADMIN_MAIL

		# Accept user input for the databse name
		vared -p "Wordpress User Password: " -c PASSWORD

		# Accept user input for the databse name
		vared -p "Site Name: " -c SITENAME

		echo "\n\n"

		theme

		echo "\nRunning Yarn"
		yarn

		echo "\nRunning Gulp"
		gulp

		root

		echo "\nRunning WP-CLI"

		wp core install --url="0.0.0.0:8080" --title="$SITENAME" --admin_user="$WPUSER" --admin_password="$PASSWORD" --admin_email="$WP_ADMIN_MAIL" --allow-root
		wp option update siteurl "http://0.0.0.0:8080/wp" --allow-root

		# show only 6 posts on an archive page, remove default tagline
		wp option update posts_per_page 6 --allow-root
		wp option update posts_per_rss 6 --allow-root
		wp option update blogdescription "" --allow-root

		# Delete sample page, and create homepage
		wp post delete $(wp post list --post_type=page --posts_per_page=1 --post_status=publish --pagename="sample-page" --field=ID --format=ids --allow-root) --allow-root
		wp post create --post_type=page --post_title=Home --post_status=publish --post_author=$(wp user get $WPUSER --field=ID --allow-root) --allow-root

		# Set homepage as front page
		wp option update show_on_front "page" --allow-root

		# Set homepage to be the new page
		wp option update page_on_front --allow-root $(wp post list --post_type=page --post_status=publish --posts_per_page=1 --pagename=home --field=ID --format=ids --allow-root)

		# Set pretty urls
		wp rewrite structure "/%postname%/" --allow-root
		wp rewrite flush --allow-root

		# Delete sample posts
		wp post delete $(wp post list --post_type='post' --format=ids --allow-root) --allow-root

		# Activate default theme
		wp theme activate wp-foundation-six --allow-root

		#Setup main navigation
		wp menu create "Main Navigation" --allow-root
		wp menu location assign main-navigation primary

		# add pages to navigation
		export IFS=" "
		for pageid in $(wp post list --order="ASC" --orderby="date" --post_type=page --post_status=publish --posts_per_page=-1 --field=ID --format=ids --allow-root); do
			wp menu item add-post main-navigation $pageid --allow-root
		done

		echo "\n\nDon't forget to:"
		echo "Update your style.css file in the base theme"
		echo "Go to http://realfavicongenerator.net/, and update your favicons/app icons\n\n"
	else
		echo "WordPress appears to already be installed, this script will not run."
	fi
}
