<!-- !/usr/bin/env markdown
-*- coding: utf-8 -*-
region header
Copyright Torben Sickert (info["~at~"]tsickert.com) 16.12.2012

License
-------

This library written by Torben Sickert stands under a creative commons naming
3.0 unported license. See https://creativecommons.org/licenses/by/3.0/deed.de
endregion -->

<!--|deDE:Projektstatus-->
Project Status
--------------

[![npm](https://img.shields.io/npm/v/containerbase?color=%23d55e5d&label=npm%20package%20version&logoColor=%23d55e5d&style=for-the-badge)](https://www.npmjs.com/package/containerbase)
[![npm downloads](https://img.shields.io/npm/dy/containerbase.svg?style=for-the-badge)](https://www.npmjs.com/package/containerbase)

[![build push package](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/build-package-and-push.yaml?label=build%20push%20package&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/build-package-and-push.yaml)
[![build push image](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/build-image-and-push-periodically-1.yaml?label=build%20push%20image&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/build-image-and-push-periodically-1.yaml)

[![test](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/test.yaml?label=test&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/test.yaml)

[![deploy web documentation](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/deploy-web-documentation.yaml?label=deploy%20web%20documentation&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/deploy-web-documentation.yaml)
[![web documentation](https://img.shields.io/website-up-down-green-red/https/tsickert.com/containerbase.svg?label=web-documentation&style=for-the-badge)](https://tsickert.com/containerbase)

<!--|deDE:Verwendung-->
Use case
--------

A basic ArchLinux based docker configuration with configured and ready to use
git and yay.

<div class="wd-table-of-contents">
    <h2 id="content">Content<!--deDE:Inhalt--><!--frFR:Contenu--></h2>
    <!--wd-table-of-contents-->
</div>

Installation
------------

You can install via package manager, simply download the compiled version as
zip file here and inject or request via CDN in HTML:
<!--deDE:
    Sie können das Paket über den Paketmanager installieren oder einfach die
    kompilierte Version als ZIP-Datei hier herunterladen und in HTML einbinden
    oder über ein CDN abrufen:
-->
<!--frFR:
    Vous pouvez installer le paquet via le gestionnaire de paquets ou
    simplement télécharger ici la version compilée sous forme de fichier ZIP,
    puis l'intégrer dans une page HTML ou la récupérer via un CDN:
-->

```bash
npm install containerbase
```

<!--|deDE:Beispiel-->
<!--|frFR:Exemple-->
Example
-------

### Jump into the image interactively

```bash
docker run --entrypoint /usr/bin/bash --interactive --tty tsickert/containerbase
```

### Run a process

```bash
docker run --env COMMAND=/path/to/executable/file tsickert/containerbase
```
