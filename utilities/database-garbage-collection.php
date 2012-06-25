<?php

/**
 * Deletes obsolete and auto-saved versions of posts
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

$query = <<<EQ1
DELETE p, tr, pm
	FROM {$table_prefix}posts AS p
	LEFT JOIN {$table_prefix}term_relationships AS tr ON (p.ID = tr.object_id)
	LEFT JOIN {$table_prefix}postmeta AS pm ON (p.ID = pm.post_id)
	WHERE p.post_type = 'revision'
EQ1;

if (false === $wpdb->query($query)) {
	die("ERROR: could not collect the garbage.");
}
