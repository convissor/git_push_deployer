<?php

/**
 * Sets the site's URL to the local one
 * @author Daniel Convissor <danielc@analysisandsolutions.com>
 * @license http://www.analysisandsolutions.com/software/license.htm Simple Public License
 * @link https://github.com/convissor/git_push_deployer
 * @package git_push_deployer
 */

/** Get the settings */
require dirname(__FILE__) . '/config.inc';

$url_old = $url_prod;
$url_new = $url_local;

/** Run the acutal code */
require dirname(__FILE__) . '/change-url-helper.inc';
