<?php

/**
 * Outputs: database host and name, separated by \n
 */

include $_SERVER['PROJECTS'] . "/huddler/config/sites/logan.huddler.com/conf/config.db.php";

echo join("\n", array(COMMUNITY_DB_HOST, COMMUNITY_DB_NAME));
