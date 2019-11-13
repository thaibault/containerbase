# region header
# [Project page](https://torben.website/containerbase)

# Copyright Torben Sickert (info["~at~"]torben.website) 16.12.2012

# License
# -------

# This library written by Torben Sickert stand under a creative commons naming
# 3.0 unported license.
# See https://creativecommons.org/licenses/by/3.0/deed.de

# Basic ArchLinux with user-mapping, AUR integration and support for decryption
# of security related files.
# endregion
# region create image commands
# Run the following command in the directory where this file lives to build a
# new docker image:
# - podman pull archlinux/base && podman build --file https://raw.githubusercontent.com/thaibault/containerbase/master/Dockerfile --no-cache --tag docker.pkg.github.com/thaibault/containerbase/base .
# - docker pull archlinux/base && docker build --no-cache --tag tsickert/base:latest https://raw.githubusercontent.com/thaibault/containerbase/master/Dockerfile
# - podman push docker.pkg.github.com/thaibault/containerbase/base:latest --creds "thaibault:$(cat "${ILU_CONFIGURATION_PATH}web/github/masterToken.txt")"
# - docker push tsickert/base
# endregion
# region start container commands
# Run the following command in the directory where this file lives to start:
# - podman pod rm --force base_pod; podman play kube kubernetes.yaml
# - docker rm --force base; docker-compose up
# endregion
            # region configuration
FROM        archlinux/base
LABEL       maintainer="Torben Sickert <info@torben.website>"
LABEL       Description="base" Vendor="thaibault products" Version="1.0"
ENV         APPLICATION_PATH /application/
ENV         APPLICATION_USER_ID_INDICATOR_FILE_PATH /application/package.json
ENV         BRANCH master
ENV         COMMAND 'echo You have to set the \"COMMAND\" environment variale.'
ENV         DECRYPT false
ENV         ENCRYPTED_PATHS "${APPLICATION_PATH}encrypted/"
ENV         DECRYPTED_PATHS "/tmp/plain/"
ENV         DEFAULT_MAIN_USER_GROUP_ID 100
ENV         DEFAULT_MAIN_USER_ID 1000
ENV         ENVIRONMENT_FILE_PATHS "/etc/containerBase/environment.sh ${APPLICATION_PATH}serviceHandler/environment.sh ${APPLICATION_PATH}environment.sh"
            # NOTE: This value has be in synchronisation with the "CMD" given
            # value.
ENV         INITIALIZING_FILE_PATH /usr/bin/initialize
ENV         INSTALLER_USER_NAME installer
ENV         KNOWN_HOSTS ''
ENV         MAIN_USER_GROUP_NAME users
ENV         MAIN_USER_NAME application
ENV         MIRROR_AREA_PATTERN Germany
ENV         PASSWORD_FILE_PATHS "${APPLICATION_PATH}.encryptionPassword"
ENV         PRIVATE_SSH_KEY ''
ENV         PUBLIC_SSH_KEY ''
            # git@github.com:thaibault/containerbase
ENV         REPOSITORY_URL https://github.com/thaibault/containerbase.git
ENV         STANDALONE true
WORKDIR     $APPLICATION_PATH
USER        root
            # endregion
            # region retrieve wget
            # Install needed base packages
RUN         pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --refresh \
                --sync \
                base \
                gnupg \
                nawk && \
            # NOTE: We should avoid leaving unnecessary data in that layer.
            rm /var/cache/* --recursive --force
            # Update mirrorlist if existing
RUN         mv \
                /etc/pacman.d/mirrorlist.pacnew \
                /etc/pacman.d/mirrorlist \
                &>/dev/null || \
                true; \
            cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig && \
            awk \
                '/^## '$MIRROR_AREA_PATTERN'$/{f=1}f==0{next}/^$/{exit}{print substr($0, 2)}' \
                /etc/pacman.d/mirrorlist.orig \
                >/etc/pacman.d/mirrorlist && \
            # Update pacman keys
            rm --force --recursive /etc/pacman.d/gnupg && \
            pacman-key --init && \
            pacman-key --populate archlinux && \
            pacman-key --refresh-keys
            # Update package database to retrieve newest package versions
RUN         pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --refresh \
                --sync \
                --sysupgrade && \
            # endregion
            # region install needed packages
            # NOTE: "neovim" is only needed for debugging scenarios.
            pacman \
                --needed \
                --noconfirm \
                --sync \
                neovim \
                openssh && \
            # NOTE: We should avoid leaving unnecessary data in that layer.
            rm /var/cache/* --recursive --force
            # endregion
            # region install needed packages
RUN         pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --sync \
                base-devel \
                gocryptfs \
                git && \
            # NOTE: We should avoid leaving unnecessary data in that layer.
            rm /var/cache/* --recursive --force && \
            echo user_allow_other >> /etc/fuse.conf && \
            mkdir --parents /etc/containerBase
            # endregion
            # region retrieve artefacts
RUN         git \
                clone \
                --depth 1 \
                --no-single-branch \
                "$REPOSITORY_URL" \
                /tmp/containerbase && \
            pushd /tmp/containerbase && \
            cp ./configure-user.sh /usr/bin/configure-user && \
            cp ./configure-runtime-user.sh /usr/bin/configure-runtime-user && \
            cp ./retrieve-application.sh /usr/bin/retrieve-application && \
            cp ./prepare-initializer.sh /usr/bin/prepare-initializer && \
            popd && \
            rm --recursive /tmp/containerbase
            # endregion
            # region configure user
RUN         configure-user && \
            # We cannot use yay as root user so we introduce an (unatted)
            # install user.
            # Create specified user with not yet existing name and id.
            useradd --create-home --no-user-group "${INSTALLER_USER_NAME}" && \
            echo \
                -e \
                "\n\n%users ALL=(ALL) ALL\n${INSTALLER_USER_NAME} ALL=(ALL) NOPASSWD:/usr/bin/pacman,/usr/bin/rm" \
                >>/etc/sudoers
            # endregion
            # region install and configure yay
USER        $INSTALLER_USER_NAME
RUN         pushd /tmp && \
            git clone https://aur.archlinux.org/yay.git && \
            pushd yay && \
            /usr/bin/makepkg --install --needed --noconfirm --syncdeps && \
            popd && \
            rm --force --recursive yay && \
            popd
USER        root
            # endregion
RUN         retrieve-application
RUN         env >/etc/default_environment
            # region bootstrap application
RUN         echo -e '#!/usr/bin/bash\n\nprepare-initializer && \\\nset -e\nsource configure-runtime-user /' \
                >"$INITIALIZING_FILE_PATH" && \
            chmod +x "$INITIALIZING_FILE_PATH"
CMD         /usr/bin/initialize
            # endregion
# region modline
# vim: set tabstop=4 shiftwidth=4 expandtab filetype=dockerfile:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
