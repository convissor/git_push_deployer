<?php

/**
 * Helper for changing the site url througout WordPress
 * @author Daniel Convissor <danielc@analysisandsolutions.com>
 * @license http://www.analysisandsolutions.com/software/license.htm Simple Public License
 * @link https://github.com/convissor/git_push_deployer
 * @package git_push_deployer
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


$query = <<<EQ3
SELECT option_id, option_name, option_value
	FROM {$table_prefix}options
	WHERE option_value LIKE '%$url_old/%'
EQ3;
$results = $wpdb->get_results($query, ARRAY_A);
if (false === $results) {
	die("ERROR: could not update 'options' table.");
}

$query = "UPDATE {$table_prefix}options
	SET option_value = %s
	WHERE option_id = %d";

foreach ($results as $row) {
	// Don't change these on the dev box.
	// Prevents spam and misinformation in the "incoming links" feed.
	if ($url_local == $url_new) {
		if ($row['option_name'] == 'dashboard_widget_options') {
			continue;
		}
	}

	$data = do_replace($row['option_value']);
	if (!is_scalar($data)) {
		$data = serialize($data);
	}

	$r = $wpdb->query($wpdb->prepare($query, $data, $row['option_id']));
	if (false === $r) {
		die("ERROR: could not update 'options' entry.");
	}
}

/**
 * Update the URL in all options, recurse into data structures as necessary
 */
function do_replace($data) {
	global $url_old, $url_new;

	if (is_serialized($data)) {
		$data = do_replace(unserialize($data));
	} elseif (is_scalar($data)) {
		$data = str_replace("$url_old/", "$url_new/", $data);
	} elseif (is_object($data)) {
		foreach ($data as $key => $value) {
			$data->$key = do_replace($value);
		}
	} else {
		foreach ($data as $key => $value) {
			$data[$key] = do_replace($value);
		}
	}

	return $data;
}

wp_cache_flush();
