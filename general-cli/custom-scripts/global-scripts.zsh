#!/bin/bash

# The global variables and aliases are used in the below functions
# They are also available in the cli container globally
SERVER_DIR='/var/www/public_html'
DATABASE_BACKUPS_DIR='/var/www/data/backups'
EJECTED_DIR='/var/www/ejected'

alias root="cd $SERVER_DIR"
alias theme="cd $SERVER_DIR/wp-content/themes/wp-foundation-six"
alias theme_components="cd $SERVER_DIR/wp-content/themes/wp-foundation-six/theme_components"

wp-theme-unit-data() {
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
	echo "If you're moving the site to http://google.com, just put google.com"
	vared -p "Production URL: " -c REPLACEURL
	REPLACEURLCLEAN=$(echo $REPLACEURL | sed -e "s/http:\/\///g")

	WORKING_DIR=$(pwd);
	cd $SERVER_DIR

	if [[ "$REPLACEURLCLEAN" ]]; then
		wp search-replace "localhost" "$REPLACEURLCLEAN" --allow-root
		wp option update siteurl "http://$REPLACEURLCLEAN" --allow-root
	fi

	wp db export $DATABASE_BACKUPS_DIR/wp_foundation_six_$(date +"%Y%m%d%H%M%s")_database.sql --allow-root

	if [[ "$REPLACEURLCLEAN" != "" ]]; then
		wp search-replace "$REPLACEURLCLEAN" "localhost" --allow-root
		wp option update siteurl "http://localhost/wp" --allow-root
	fi

	cd $WORKING_DIR

	echo "\n"
}

wp-init() {
	WORKING_DIR=$(pwd);

	echo "\n\n"

	local WPUSER
	local WP_ADMIN_MAIL
	local PASSWORD
	local SITENAME

	# Accept user input for the Username name
	read "WPUSER?Wordpress Username: "

	# Accept user input for the Email Address name
	read "WP_ADMIN_MAIL?Wordpress User Email Address: "

	# Accept user input for the User Password name
	read -s "PASSWORD?Wordpress User Password: "
	echo ""

	# Accept user input for the Site Name name
	read "SITENAME?Site Name: "

	echo "\n\n"

	cd $SERVER_DIR

	echo "\nRunning Composer to install WordPress Files"
	composer install

    if ! $(wp core is-installed); then
    	# Change table prefix before setting up WordPress database
    	echo "\nUpdating WordPress table prefix"
    	NEW_VALUE=$(tr -cd 'a-z' < /dev/urandom | fold -w4 | head -n1)
    	TABLE_PREFIX="\$table_prefix  = 'wp_';"
    	TABLE_PREFIX_NEW="\$table_prefix  = '"$NEW_VALUE"_';"
    	sed -i "/$TABLE_PREFIX/c\\$TABLE_PREFIX_NEW" ./wp-config.php

    	# cd into theme
		cd $SERVER_DIR/wp-content/themes/wp-foundation-six

		echo "\nRunning NPM"
		npm install

		echo "\nRunning Gulp"
		gulp

		cd $SERVER_DIR

		echo "\nRunning WP-CLI"

		wp core install --url="localhost" --title="$SITENAME" --admin_user="$WPUSER" --admin_password="$PASSWORD" --admin_email="$WP_ADMIN_MAIL" --allow-root
		wp option update siteurl "http://localhost/wp" --allow-root

		wp user update $WPUSER --admin_color=light --show_admin_bar_front=false --allow-root

		# show only 6 posts on an archive page, remove default tagline
		wp option update posts_per_page 6 --allow-root
		wp option update posts_per_rss 6 --allow-root
		wp option update blogdescription "" --allow-root
		wp option update timezone_string America/Chicago --allow-root

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
		wp menu location assign main-navigation primary --allow-root

		# add pages to navigation
		export IFS=" "
		for pageid in $(wp post list --order="ASC" --orderby="date" --post_type=page --post_status=publish --posts_per_page=-1 --field=ID --format=ids --allow-root); do
			wp menu item add-post main-navigation $pageid --allow-root
		done

		echo "\n\nDon't forget to:"
		echo "Update your style.css file in the base theme"
		echo "Go to http://realfavicongenerator.net/, and update your favicons/app icons\n\n"

		cd $WORKING_DIR
	else
		echo "WordPress appears to already be installed, this script will not run."

		cd $WORKING_DIR
	fi
}

wp-eject() {
	if [ -d "$EJECTED_DIR" ]; then
		WORKING_DIR=$(pwd);

		cd $EJECTED_DIR
		EJECTED_PROJECT_DIR=wp_foundation_six_$(date +"%Y%m%d%H%M%s")
		take $EJECTED_PROJECT_DIR

		wp core download --allow-root

		rm -rf wp-content

		rsync -av --progress $SERVER_DIR/wp-content ./ --exclude wp-foundation-six

		if [ -d "$SERVER_DIR/wp-content/themes/wp-foundation-six" ]; then

			cd $SERVER_DIR/wp-content/themes/wp-foundation-six

			npm install

			gulp --build

			cd $EJECTED_DIR/$EJECTED_PROJECT_DIR

			rsync -av --progress $SERVER_DIR/wp-content/themes/wp-foundation-six-build ./wp-content/themes

			mv ./wp-content/themes/wp-foundation-six-build ./wp-content/themes/wp-foundation-six

			cp $EJECTED_DIR/server-assets/.htaccess ./.htaccess
			cp $EJECTED_DIR/server-assets/robots-dev.txt ./robots-dev.txt
			cp $EJECTED_DIR/server-assets/robots.txt ./robots.txt

			cd $EJECTED_DIR

			zip -r $EJECTED_PROJECT_DIR.zip $EJECTED_PROJECT_DIR

			rm -rf $EJECTED_PROJECT_DIR
			rm -rf $SERVER_DIR/wp-content/themes/wp-foundation-six-build

			cd $SERVER_DIR/wp-content/themes/wp-foundation-six

			gulp

			cd $WORKING_DIR

			wp-db-export
		else
			echo "The $SERVER_DIR/wp-content/themes/wp-foundation-six directory does not exist"
			echo "The theme must be named wp-foundation-six for this script to work"
		fi
	else
		echo "The $EJECTED_DIR directory does not exist"
	fi
}
