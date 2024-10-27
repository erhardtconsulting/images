<?php
$CONFIG = array(
    'datadirectory' => '/data/data',
    'tempdirectory' => '/data/tmp',
    'supportedDatabases' => array(
        'sqlite',
        'mysql',
        'pgsql'
    ),
    'memcache.local' => '\OC\Memcache\APCu',
    'apps_paths' => array(
        array(
            'path' => '/opt/nextcloud/apps',
            'url' => '/apps',
            'writable' => false,
        ),
        array(
            'path' => '/data/userapps',
            'url' => '/userapps',
            'writable' => true,
        ),
    ),
    'log_type' => 'file',
    'logfile' => '/data/logs/nextcloud.log',
    'loglevel' => 3,
    'logdateformat' => 'F d, Y H:i:s',
    'upgrade.disable-web' => true,
);
