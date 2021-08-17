<?php

$_GET['sqlite'] = '';

function adminer_object()
{
    require "./plugins/fc-sqlite-connection-without-credentials.php";
    require "./plugins/plugin.php";

    foreach (glob("plugins/*.php") as $filename) {
        include_once "./$filename";
    }

    $plugins = [
        new AdminerDumpXml(),
        new AdminerTinymce(),
        new AdminerFileUpload("data/"),
        new AdminerSlugify(),
        new AdminerTranslation(),
        new AdminerForeignSystem(),
        new FCSqliteConnectionWithoutCredentials()
    ];

    return new AdminerPlugin($plugins);
}

include "./adminer.php";
?>