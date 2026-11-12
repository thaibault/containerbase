<!-- !/usr/bin/env markdown
-*- coding: utf-8 -*-
region header
Copyright Torben Sickert (info["~at~"]tsickert.com) 16.12.2012

License
-------

This library written by Torben Sickert stands under a creative commons naming
4.0 international license.
See https://creativecommons.org/licenses/by/4.0/deed.de
endregion -->

<!--|deDE:Projektstatus-->
<!--|frFR:Statut du projet-->
Project Status
--------------

[![npm](https://img.shields.io/npm/v/containerbase?color=%23d55e5d&label=npm%20package%20version&logoColor=%23d55e5d&style=for-the-badge)](https://www.npmjs.com/package/containerbase)
[![npm downloads](https://img.shields.io/npm/dy/containerbase.svg?style=for-the-badge)](https://www.npmjs.com/package/containerbase)

[![build push package](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/build-package-and-push.yaml?label=build%20push%20package&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/build-package-and-push.yaml)
[![build push image](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/build-image-and-push-periodically-1.yaml?label=build%20push%20image&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/build-image-and-push-periodically-1.yaml)

[![lint](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/lint.yaml?label=lint&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/lint.yaml)
[![test](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/test.yaml?label=test&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/test.yaml)
[![test image](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/test-image.yaml?label=test%20image&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/test-image.yaml)

[![deploy web documentation](https://img.shields.io/github/actions/workflow/status/thaibault/containerbase/deploy-web-documentation.yaml?label=deploy%20web%20documentation&style=for-the-badge)](https://github.com/thaibault/containerbase/actions/workflows/deploy-web-documentation.yaml)
[![web documentation](https://img.shields.io/website-up-down-green-red/https/tsickert.com/containerbase.svg?label=web-documentation&style=for-the-badge)](https://tsickert.com/containerbase)


<!--|deDE:Einsatzmöglichkeiten-->
<!--|frFR:Cas d'utilisation-->
Use case
--------

An [Arch Linux](https://archlinux.org) based container image for x86-64 and
ARM64 to build your own application images on. It takes care of the parts
every containerized application needs: running the application as an
unprivileged user that matches the owner of your files on the host, decrypting
secrets on startup and installing additional packages, including packages from
the Arch User Repository.
<!--deDE:
    Ein auf [Arch Linux](https://archlinux.org) basierendes Container-Image
    für x86-64 und ARM64, auf dem Sie eigene Anwendungs-Images aufbauen. Es
    übernimmt, was jede containerisierte Anwendung braucht: die Anwendung als
    unprivilegierten Benutzer auszuführen, der dem Besitzer Ihrer Dateien auf
    dem Host entspricht, Geheimnisse beim Start zu entschlüsseln und
    zusätzliche Pakete zu installieren, auch aus dem Arch User Repository.
-->
<!--frFR:
    Une image de conteneur basée sur [Arch Linux](https://archlinux.org) pour
    x86-64 et ARM64, sur laquelle vous construisez vos propres images
    d'application. Elle prend en charge ce dont toute application conteneurisée
    a besoin: exécuter l'application avec un utilisateur non privilégié
    correspondant au propriétaire de vos fichiers sur l'hôte, déchiffrer les
    secrets au démarrage et installer des paquets supplémentaires, y compris
    depuis l'Arch User Repository.
-->

Features included:
<!--deDE:Enthaltene Funktionen:-->
<!--frFR:Fonctionnalités incluses:-->

- Up-to-date Arch Linux with "base-devel", "git", "openssh" and "neovim",
  rebuilt regularly.<!--deDE:Aktuelles Arch Linux mit "base-devel", "git", "openssh" und "neovim", regelmäßig neu gebaut.--><!--frFR:Arch Linux à jour avec "base-devel", "git", "openssh" et "neovim", reconstruit régulièrement.-->
- AUR helper [aura](https://github.com/fosskers/aura) on x86-64.<!--deDE:AUR-Helfer [aura](https://github.com/fosskers/aura) auf x86-64.--><!--frFR:Assistant AUR [aura](https://github.com/fosskers/aura) sur x86-64.-->
- Maps the application user to the user and group id of your files on the
  host.<!--deDE:Ordnet den Anwendungsbenutzer der Benutzer- und Gruppen-ID Ihrer Dateien auf dem Host zu.--><!--frFR:Fait correspondre l'utilisateur de l'application aux identifiants d'utilisateur et de groupe de vos fichiers sur l'hôte.-->
- Decrypts GPG encrypted files on startup with a password from a Docker
  secret, a file or an environment variable.<!--deDE:Entschlüsselt GPG-verschlüsselte Dateien beim Start mit einem Passwort aus einem Docker-Secret, einer Datei oder einer Umgebungsvariable.--><!--frFR:Déchiffre au démarrage les fichiers chiffrés avec GPG à l'aide d'un mot de passe provenant d'un secret Docker, d'un fichier ou d'une variable d'environnement.-->
- Optionally clones your application from a git repository at build time.<!--deDE:Klont Ihre Anwendung optional beim Bauen aus einem Git-Repository.--><!--frFR:Clone éventuellement votre application depuis un dépôt git lors de la construction.-->
- Includes the [bashlink](https://tsickert.com/bashlink) shell library.<!--deDE:Enthält die Shell-Bibliothek [bashlink](https://tsickert.com/bashlink).--><!--frFR:Inclut la bibliothèque shell [bashlink](https://tsickert.com/bashlink).-->

<div class="wd-table-of-contents">
    <h2 id="content">Content<!--deDE:Inhalt--><!--frFR:Contenu--></h2>
    <!--wd-table-of-contents-->
</div>

<!--|deDE:Schnellstart-->
<!--|frFR:Démarrage rapide-->
Quick start
-----------

Open a shell in the image:
<!--deDE:Eine Shell im Image öffnen:-->
<!--frFR:Ouvrir un shell dans l'image:-->

```bash
docker run --entrypoint /usr/bin/bash --interactive --rm --tty \
    ghcr.io/thaibault/containerbase:latest
```

Run a command as application user:
<!--deDE:Einen Befehl als Anwendungsbenutzer ausführen:-->
<!--frFR:Exécuter une commande en tant qu'utilisateur de l'application:-->

```bash
docker run --env COMMAND="echo 'whoami'" --rm \
    ghcr.io/thaibault/containerbase:latest
```

<!--|deDE:Eigenes Image bauen-->
<!--|frFR:Construire votre propre image-->
Building your own image
-----------------------

Start from the image, install what your application needs, copy it to
"/application/" and tell the image how to start it. This example runs a
Node.js script:
<!--deDE:
    Gehen Sie vom Image aus, installieren Sie, was Ihre Anwendung braucht,
    kopieren Sie sie nach "/application/" und legen Sie fest, wie sie
    gestartet wird. Dieses Beispiel führt ein Node.js-Skript aus:
-->
<!--frFR:
    Partez de l'image, installez ce dont votre application a besoin,
    copiez-la dans "/application/" et indiquez comment la démarrer. Cet
    exemple exécute un script Node.js:
-->

```Dockerfile
FROM        ghcr.io/thaibault/containerbase:latest

USER        $INSTALLER_USER_NAME
RUN         pacman-wrapper \
                --noconfirm --refresh --sync --sysupgrade nodejs && \
            clean-up
USER        root

COPY        --chown=application:users . $APPLICATION_PATH

ENV         COMMAND="echo 'node index.js'"
```

- Install packages as user "installer" with "pacman-wrapper". It uses aura if
  available, so AUR packages work as well, otherwise pacman. Always update the
  whole system along with it, Arch Linux does not support partial upgrades.<!--deDE:Installieren Sie Pakete als Benutzer "installer" mit "pacman-wrapper". Es verwendet aura, falls vorhanden, sodass auch AUR-Pakete funktionieren, sonst pacman. Aktualisieren Sie dabei immer das gesamte System, Arch Linux unterstützt keine Teilaktualisierungen.--><!--frFR:Installez les paquets en tant qu'utilisateur "installer" avec "pacman-wrapper". Il utilise aura s'il est disponible, ce qui permet aussi d'installer des paquets AUR, sinon pacman. Mettez toujours à jour l'ensemble du système en même temps, Arch Linux ne prend pas en charge les mises à jour partielles.-->
- "clean-up" removes package caches and orphaned packages to keep the image
  small. Pass package names to remove them as well.<!--deDE:"clean-up" entfernt Paket-Caches und verwaiste Pakete, um das Image klein zu halten. Übergeben Sie Paketnamen, um auch diese zu entfernen.--><!--frFR:"clean-up" supprime les caches de paquets et les paquets orphelins pour garder l'image légère. Indiquez des noms de paquets pour les supprimer également.-->
- The owner of "/application/package.json" decides which user runs the
  application, see [user mapping](#wd-heading-user-mapping). Without
  "--chown" it is "root".<!--deDE:Der Besitzer von "/application/package.json" bestimmt, welcher Benutzer die Anwendung ausführt, siehe [Benutzerzuordnung](#wd-heading-user-mapping). Ohne "--chown" ist das "root".--><!--frFR:Le propriétaire de "/application/package.json" détermine l'utilisateur qui exécute l'application, voir [correspondance des utilisateurs](#wd-heading-user-mapping). Sans "--chown", c'est "root".-->

<!--|deDE:Der Startbefehl-->
<!--|frFR:La commande de démarrage-->
### The start command

"COMMAND" is evaluated by the shell on startup and its output is the command
which is run. This allows composing the command from environment variables
which are only known at runtime. Arguments given to "docker run" after the
image name are appended before evaluation:
<!--deDE:
    "COMMAND" wird beim Start von der Shell ausgewertet, und seine Ausgabe ist
    der Befehl, der ausgeführt wird. So lässt sich der Befehl aus
    Umgebungsvariablen zusammensetzen, die erst zur Laufzeit bekannt sind.
    Argumente, die "docker run" nach dem Image-Namen erhält, werden vor der
    Auswertung angehängt:
-->
<!--frFR:
    "COMMAND" est évalué par le shell au démarrage et sa sortie est la
    commande exécutée. Cela permet de composer la commande à partir de
    variables d'environnement connues uniquement à l'exécution. Les arguments
    passés à "docker run" après le nom de l'image sont ajoutés avant
    l'évaluation:
-->

```bash
docker run --env COMMAND="echo echo" --rm \
    ghcr.io/thaibault/containerbase:latest hello world
# Prints "hello world".
```

<!--|deDE:Ablauf beim Start-->
<!--|frFR:Déroulement au démarrage-->
### Startup sequence

The entry point "/usr/bin/initialize" runs these steps:
<!--deDE:Der Einstiegspunkt "/usr/bin/initialize" führt diese Schritte aus:-->
<!--frFR:Le point d'entrée "/usr/bin/initialize" exécute ces étapes:-->

1. Hands over to an "initialize.sh" next to one of the environment files if
   present, so your application can replace the whole sequence.<!--deDE:Übergibt an ein "initialize.sh" neben einer der Umgebungsdateien, falls vorhanden, sodass Ihre Anwendung den gesamten Ablauf ersetzen kann.--><!--frFR:Passe la main à un "initialize.sh" situé à côté de l'un des fichiers d'environnement s'il existe, afin que votre application puisse remplacer toute la séquence.-->
2. Loads the environment files "/etc/containerBase/environment.sh",
   "/application/serviceHandler/environment.sh" and
   "/application/environment.sh" if they exist.<!--deDE:Lädt die Umgebungsdateien "/etc/containerBase/environment.sh", "/application/serviceHandler/environment.sh" und "/application/environment.sh", sofern vorhanden.--><!--frFR:Charge les fichiers d'environnement "/etc/containerBase/environment.sh", "/application/serviceHandler/environment.sh" et "/application/environment.sh" s'ils existent.-->
3. Decrypts encrypted files if "DECRYPT" is "true".<!--deDE:Entschlüsselt verschlüsselte Dateien, wenn "DECRYPT" auf "true" steht.--><!--frFR:Déchiffre les fichiers chiffrés si "DECRYPT" vaut "true".-->
4. Maps the application user to the host ids.<!--deDE:Ordnet den Anwendungsbenutzer den Host-IDs zu.--><!--frFR:Fait correspondre l'utilisateur de l'application aux identifiants de l'hôte.-->
5. Runs the command as application user, or as "root" if mapped to it.<!--deDE:Führt den Befehl als Anwendungsbenutzer aus oder als "root", falls diesem zugeordnet.--><!--frFR:Exécute la commande en tant qu'utilisateur de l'application, ou en tant que "root" si c'est à lui qu'il correspond.-->

<!--|deDE:Benutzerzuordnung-->
<!--|frFR:Correspondance des utilisateurs-->
User mapping
------------

Files written by your application into mounted host directories should belong
to you, not to an unknown user id. On startup the image therefore changes the
user and group ids of its application user "application" to the ids given in
"HOST_USER_ID" and "HOST_USER_GROUP_ID". If they are not set, the owner of
"/application/package.json" is used. Mounting your project to
"/application/" is therefore enough during development:
<!--deDE:
    Dateien, die Ihre Anwendung in eingebundene Host-Verzeichnisse schreibt,
    sollen Ihnen gehören und nicht einer unbekannten Benutzer-ID. Beim Start
    ändert das Image deshalb die Benutzer- und Gruppen-ID seines
    Anwendungsbenutzers "application" auf die in "HOST_USER_ID" und
    "HOST_USER_GROUP_ID" angegebenen IDs. Sind diese nicht gesetzt, wird der
    Besitzer von "/application/package.json" verwendet. Während der
    Entwicklung genügt es daher, Ihr Projekt nach "/application/"
    einzubinden:
-->
<!--frFR:
    Les fichiers que votre application écrit dans des répertoires montés de
    l'hôte doivent vous appartenir et non à un identifiant inconnu. Au
    démarrage, l'image modifie donc les identifiants d'utilisateur et de
    groupe de son utilisateur d'application "application" pour adopter ceux
    indiqués dans "HOST_USER_ID" et "HOST_USER_GROUP_ID". S'ils ne sont pas
    définis, le propriétaire de "/application/package.json" est utilisé. En
    développement, il suffit donc de monter votre projet dans
    "/application/":
-->

```bash
docker run --rm --volume "$(pwd):/application" your-image
```

If the ids resolve to "0" the command runs as "root". Change the reference
file via "APPLICATION_USER_ID_INDICATOR_FILE_PATH".
<!--deDE:
    Ergeben sich die IDs zu "0", läuft der Befehl als "root". Die
    Referenzdatei ändern Sie über "APPLICATION_USER_ID_INDICATOR_FILE_PATH".
-->
<!--frFR:
    Si les identifiants valent "0", la commande s'exécute en tant que
    "root". Modifiez le fichier de référence via
    "APPLICATION_USER_ID_INDICATOR_FILE_PATH".
-->

<!--|deDE:Verschlüsselte Dateien-->
<!--|frFR:Fichiers chiffrés-->
Encrypted files
---------------

Keep secrets like certificates or credentials encrypted in your repository
and image. Encrypt a directory with GPG using the included "crypt" script:
<!--deDE:
    Halten Sie Geheimnisse wie Zertifikate oder Zugangsdaten verschlüsselt in
    Ihrem Repository und Image. Verschlüsseln Sie ein Verzeichnis mit GPG über
    das enthaltene Skript "crypt":
-->
<!--frFR:
    Conservez les secrets tels que certificats ou identifiants chiffrés dans
    votre dépôt et votre image. Chiffrez un répertoire avec GPG à l'aide du
    script "crypt" inclus:
-->

```bash
docker run --entrypoint crypt --rm --volume "$(pwd):/work" --workdir /work \
    ghcr.io/thaibault/containerbase:latest \
    --password-file password plain/ encrypted/
```

Each file is stored with a ".gpg" suffix. Put the result to
"/application/encrypted/" and start the container with "DECRYPT=true". The
files are then available unencrypted below "/tmp/plain/". The password is
taken from the first available source:
<!--deDE:
    Jede Datei wird mit der Endung ".gpg" gespeichert. Legen Sie das Ergebnis
    unter "/application/encrypted/" ab und starten Sie den Container mit
    "DECRYPT=true". Die Dateien liegen dann unverschlüsselt unterhalb von
    "/tmp/plain/". Das Passwort wird aus der ersten verfügbaren Quelle
    gelesen:
-->
<!--frFR:
    Chaque fichier est enregistré avec le suffixe ".gpg". Placez le résultat
    dans "/application/encrypted/" et démarrez le conteneur avec
    "DECRYPT=true". Les fichiers sont alors disponibles en clair sous
    "/tmp/plain/". Le mot de passe est lu à partir de la première source
    disponible:
-->

1. Docker secret "encryption_password", i.e. "/run/secrets/encryption_password".<!--deDE:Docker-Secret "encryption_password", also "/run/secrets/encryption_password".--><!--frFR:Secret Docker "encryption_password", c'est-à-dire "/run/secrets/encryption_password".-->
2. File "/application/.encryptionPassword".<!--deDE:Datei "/application/.encryptionPassword".--><!--frFR:Fichier "/application/.encryptionPassword".-->
3. Environment variable "DECRYPTION_PASSWORD".<!--deDE:Umgebungsvariable "DECRYPTION_PASSWORD".--><!--frFR:Variable d'environnement "DECRYPTION_PASSWORD".-->

```bash
docker run --env DECRYPT=true --env DECRYPTION_PASSWORD=secret --rm your-image
```

"ENCRYPTED_PATHS", "DECRYPTED_PATHS", "PASSWORD_SECRET_NAMES" and
"PASSWORD_FILE_PATHS" accept space separated lists to handle several
directories with different passwords. "encrypt" does the reverse based on the
same settings.
<!--deDE:
    "ENCRYPTED_PATHS", "DECRYPTED_PATHS", "PASSWORD_SECRET_NAMES" und
    "PASSWORD_FILE_PATHS" akzeptieren durch Leerzeichen getrennte Listen, um
    mehrere Verzeichnisse mit unterschiedlichen Passwörtern zu verarbeiten.
    "encrypt" macht anhand derselben Einstellungen das Umgekehrte.
-->
<!--frFR:
    "ENCRYPTED_PATHS", "DECRYPTED_PATHS", "PASSWORD_SECRET_NAMES" et
    "PASSWORD_FILE_PATHS" acceptent des listes séparées par des espaces pour
    traiter plusieurs répertoires avec des mots de passe différents.
    "encrypt" effectue l'opération inverse à partir des mêmes réglages.
-->

<!--|deDE:Anwendung aus Git laden-->
<!--|frFR:Récupérer l'application depuis git-->
Retrieving the application from git
-----------------------------------

Instead of copying files, an image can clone its application at build time.
Set "REPOSITORY_URL", "PRIVATE_SSH_KEY", "PUBLIC_SSH_KEY" and "KNOWN_HOSTS",
optionally the build argument "BRANCH_NAME" (default "main"), and run
"retrieve-application". It clones the repository including submodules to
"/application/" and removes the git metadata afterwards.
<!--deDE:
    Statt Dateien zu kopieren, kann ein Image seine Anwendung beim Bauen
    klonen. Setzen Sie "REPOSITORY_URL", "PRIVATE_SSH_KEY", "PUBLIC_SSH_KEY"
    und "KNOWN_HOSTS", optional das Build-Argument "BRANCH_NAME" (Standard
    "main"), und führen Sie "retrieve-application" aus. Es klont das
    Repository samt Submodulen nach "/application/" und entfernt anschließend
    die Git-Metadaten.
-->
<!--frFR:
    Au lieu de copier des fichiers, une image peut cloner son application lors
    de la construction. Définissez "REPOSITORY_URL", "PRIVATE_SSH_KEY",
    "PUBLIC_SSH_KEY" et "KNOWN_HOSTS", éventuellement l'argument de
    construction "BRANCH_NAME" (par défaut "main"), puis exécutez
    "retrieve-application". Il clone le dépôt avec ses sous-modules dans
    "/application/" et supprime ensuite les métadonnées git.
-->

<!--|deDE:Umgebungsvariablen-->
<!--|frFR:Variables d'environnement-->
Environment variables
---------------------

- "COMMAND": Command generator, see above.<!--deDE:"COMMAND": Befehlsgenerator, siehe oben.--><!--frFR:"COMMAND": Générateur de commande, voir ci-dessus.-->
- "APPLICATION_PATH": Application directory, "/application/".<!--deDE:"APPLICATION_PATH": Anwendungsverzeichnis, "/application/".--><!--frFR:"APPLICATION_PATH": Répertoire de l'application, "/application/".-->
- "ENVIRONMENT_FILE_PATHS": Shell files loaded on startup.<!--deDE:"ENVIRONMENT_FILE_PATHS": Beim Start geladene Shell-Dateien.--><!--frFR:"ENVIRONMENT_FILE_PATHS": Fichiers shell chargés au démarrage.-->
- "MAIN_USER_NAME" and "MAIN_USER_GROUP_NAME": Application user and group,
  "application" and "users".<!--deDE:"MAIN_USER_NAME" und "MAIN_USER_GROUP_NAME": Anwendungsbenutzer und -gruppe, "application" und "users".--><!--frFR:"MAIN_USER_NAME" et "MAIN_USER_GROUP_NAME": Utilisateur et groupe de l'application, "application" et "users".-->
- "HOST_USER_ID", "HOST_USER_GROUP_ID" and
  "APPLICATION_USER_ID_INDICATOR_FILE_PATH": User mapping.<!--deDE:"HOST_USER_ID", "HOST_USER_GROUP_ID" und "APPLICATION_USER_ID_INDICATOR_FILE_PATH": Benutzerzuordnung.--><!--frFR:"HOST_USER_ID", "HOST_USER_GROUP_ID" et "APPLICATION_USER_ID_INDICATOR_FILE_PATH": Correspondance des utilisateurs.-->
- "DECRYPT", "ENCRYPTED_PATHS", "DECRYPTED_PATHS", "DECRYPTION_PASSWORD",
  "PASSWORD_SECRET_NAMES" and "PASSWORD_FILE_PATHS": Encrypted files.<!--deDE:"DECRYPT", "ENCRYPTED_PATHS", "DECRYPTED_PATHS", "DECRYPTION_PASSWORD", "PASSWORD_SECRET_NAMES" und "PASSWORD_FILE_PATHS": Verschlüsselte Dateien.--><!--frFR:"DECRYPT", "ENCRYPTED_PATHS", "DECRYPTED_PATHS", "DECRYPTION_PASSWORD", "PASSWORD_SECRET_NAMES" et "PASSWORD_FILE_PATHS": Fichiers chiffrés.-->
- "REPOSITORY_URL", "PRIVATE_SSH_KEY", "PUBLIC_SSH_KEY", "KNOWN_HOSTS" and
  "STANDALONE": Retrieving the application.<!--deDE:"REPOSITORY_URL", "PRIVATE_SSH_KEY", "PUBLIC_SSH_KEY", "KNOWN_HOSTS" und "STANDALONE": Laden der Anwendung.--><!--frFR:"REPOSITORY_URL", "PRIVATE_SSH_KEY", "PUBLIC_SSH_KEY", "KNOWN_HOSTS" et "STANDALONE": Récupération de l'application.-->

<!--|deDE:Basis-Image selbst bauen-->
<!--|frFR:Construire l'image de base soi-même-->
Building the base image
-----------------------

The image is bootstrapped from scratch with pacman, so it can be built for
several architectures:
<!--deDE:
    Das Image wird mit pacman von Grund auf aufgebaut und kann daher für
    mehrere Architekturen gebaut werden:
-->
<!--frFR:
    L'image est amorcée à partir de zéro avec pacman et peut donc être
    construite pour plusieurs architectures:
-->

```bash
docker buildx build --platform linux/amd64,linux/arm64 \
    --tag ghcr.io/thaibault/containerbase:latest .
```

- "MIRROR_AREA_PATTERN": Restrict the pacman mirror list to a region, e.g.
  "Germany".<!--deDE:"MIRROR_AREA_PATTERN": Beschränkt die pacman-Spiegelliste auf eine Region, z. B. "Germany".--><!--frFR:"MIRROR_AREA_PATTERN": Limite la liste des miroirs pacman à une région, par exemple "Germany".-->
- A file "custom-root-ca.crt" next to the Dockerfile is trusted while
  bootstrapping, e.g. behind a company proxy.<!--deDE:Einer Datei "custom-root-ca.crt" neben dem Dockerfile wird beim Aufbau des Systems vertraut, z. B. hinter einem Firmen-Proxy.--><!--frFR:Un fichier "custom-root-ca.crt" placé à côté du Dockerfile est considéré comme fiable pendant l'amorçage du système, par exemple derrière un proxy d'entreprise.-->

<!--|deDE:Entwicklung-->
<!--|frFR:Développement-->
Development
-----------

```bash
yarn install
yarn lint
yarn test
```
