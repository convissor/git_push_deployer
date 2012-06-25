<?php

/**
 * Helper for changing the site url througout WordPress
 * @author Daniel Convissor <danielc@analysisandsolutions.com>
 * @license http://www.analysisandsolutions.com/software/license.htm Simple Public License
 */

/**#@+
 * Gather WordPress infrastructure
 */
require_once dirname(dirname(__FILE__)) . '/public_html/wp-load.php';
/**#@-*/

update_option('siteurl', $url_new);
update_option('home', $url_new);

$query = <<<EQ1
UPDATE {$table_prefix}posts SET
	post_content = REPLACE(post_content, '$url_old/', '$url_new/'),
	guid = REPLACE(guid, '$url_old/', '$url_new/');
EQ1;
if (false === $wpdb->query($query)) {
	die("ERROR: could not update 'posts' table.");
}

wp_cache_reset();
