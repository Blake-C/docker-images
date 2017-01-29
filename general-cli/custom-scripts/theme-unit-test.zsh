#!/bin/zsh

theme-unit-test () {
	curl https://wpcom-themes.svn.automattic.com/demo/theme-unit-test-data.xml >> theme-unit-test-data.xml
	wp plugin install wordpress-importer --activate --allow-root
	wp import theme-unit-test-data.xml --authors=create --allow-root
	rm theme-unit-test-data.xml
}