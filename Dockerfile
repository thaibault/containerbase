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

# x86_64

# - podman pull archlinux && podman build --file https://raw.githubusercontent.com/thaibault/containerbase/master/Dockerfile --no-cache --tag ghcr.io/thaibault/containerbase:latest-x86-64 .
# - podman push ghcr.io/thaibault/containerbase:latest-x86-64 --creds "thaibault:$(cat "${ILU_GITHUB_BASE_CONFIGURATION_PATH}masterToken.txt")"

# - docker pull archlinux && docker build --no-cache --tag ghcr.io/thaibault/containerbase:latest-x86_64 https://raw.githubusercontent.com/thaibault/containerbase/master/Dockerfile
# - cat "${ILU_GITHUB_BASE_CONFIGURATION_PATH}masterToken.txt" | docker login ghcr.io --username thaibault --password-stdin && docker push ghcr.io/thaibault/containerbase:latest-x86-64

# arm_64

# - docker pull heywoodlh/archlinux && docker build --build-arg BASE_IMAGE=heywoodlh/archlinux --build-arg MIRROR_AREA_PATTERN=default --no-cache --tag ghcr.io/thaibault/containerbase:latest-arm-64 https://raw.githubusercontent.com/thaibault/containerbase/master/Dockerfile
# - cat "${ILU_GITHUB_BASE_CONFIGURATION_PATH}masterToken.txt" | docker login ghcr.io --username thaibault --password-stdin && docker push ghcr.io/thaibault/containerbase:latest-arm-64
# endregion
# region start container commands
# Run the following command in the directory where this file lives to start:
# - podman pod rm --force base_pod; podman play kube kubernetes.yaml
# - docker rm --force base; docker compose up
# endregion
            # region configuration
ARG         BASE_IMAGE

FROM        ${BASE_IMAGE:-archlinux}

LABEL       maintainer="Torben Sickert <info@torben.website>"
LABEL       Description="base" Vendor="thaibault products" Version="1.0"

ENV         APPLICATION_PATH /application/
ENV         ENVIRONMENT_FILE_PATHS "/etc/containerBase/environment.sh ${APPLICATION_PATH}serviceHandler/environment.sh ${APPLICATION_PATH}environment.sh"

ENV         COMMAND 'echo You have to set the \"COMMAND\" environment variale.'
            # NOTE: This value has be in synchronisation with the "CMD" given
            # value.
ENV         INITIALIZING_FILE_PATH /usr/bin/initialize

ENV         DECRYPT false
ENV         DECRYPT_AS_USER true
ENV         DECRYPTED_PATHS "/tmp/plain/"
ENV         ENCRYPTED_PATHS "${APPLICATION_PATH}encrypted/"
ENV         PASSWORD_SECRET_NAMES encryption_password
ENV         PASSWORD_FILE_PATHS "${APPLICATION_PATH}.encryptionPassword"

ENV         APPLICATION_USER_ID_INDICATOR_FILE_PATH /application/package.json
ENV         DEFAULT_MAIN_USER_GROUP_ID 100
ENV         DEFAULT_MAIN_USER_ID 1000
ENV         INSTALLER_USER_NAME installer
ENV         MAIN_USER_GROUP_NAME users
ENV         MAIN_USER_NAME application

ENV         KNOWN_HOSTS ''

ARG         MIRROR_AREA_PATTERN='United States'

ENV         PRIVATE_SSH_KEY ''
ENV         PUBLIC_SSH_KEY ''
            # git@github.com:thaibault/containerbase
ENV         REPOSITORY_URL https://github.com/thaibault/containerbase.git
            # NOTE: Do not set as environment variable to avoid shadowing this
            # argument in inherited image builds.
ARG         BRANCH_NAME

ENV         STANDALONE true

WORKDIR     $APPLICATION_PATH

USER        root
            # endregion
            # region install needed base packages
RUN         pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --refresh \
                --sync \
                base \
                nawk && \
            # NOTE: We should avoid leaving unnecessary data in that layer.
            rm /var/cache/* --recursive --force
            # Update mirrorlist if existing
RUN         [[ "$MIRROR_AREA_PATTERN" != default ]] && \
            [ -f /etc/pacman.d/mirrorlist.pacnew ] && \
            mv \
                /etc/pacman.d/mirrorlist.pacnew \
                /etc/pacman.d/mirrorlist \
                &>/dev/null || \
                true; \
            [[ "$MIRROR_AREA_PATTERN" != default ]] && \
            cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig && \
            awk \
                '/^## '$MIRROR_AREA_PATTERN'$/{f=1}f==0{next}/^$/{exit}{print substr($0, 2)}' \
                /etc/pacman.d/mirrorlist.orig \
                >/etc/pacman.d/mirrorlist && \
            # Update pacman keys (is optional and sometimes not working)
            #rm --force --recursive /etc/pacman.d/gnupg && \
            #pacman-key --init && \
            #pacman-key --populate archlinux && \
            #pacman-key --refresh-keys
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
                --noprogressbar \
                neovim \
                openssh && \
            # NOTE: We should avoid leaving unnecessary data in that layer.
            rm /var/cache/* --recursive --force
            # endregion
            # region install packages to build other packages
RUN         pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --sync \
                base-devel \
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
            git checkout "${BRANCH_NAME:-master}" && \
            cp ./scripts/configure-runtime-user.sh /usr/bin/configure-runtime-user && \
            cp ./scripts/configure-user.sh /usr/bin/configure-user && \
            cp ./scripts/decrypt.sh /usr/bin/decrypt && \
            cp ./scripts/encrypt.sh /usr/bin/encrypt && \
            cp ./scripts/initialize.sh /usr/bin/initialize && \
            cp ./scripts/prepare-initializer.sh /usr/bin/prepare-initializer && \
            cp ./scripts/retrieve-application.sh /usr/bin/retrieve-application && \
            cp ./scripts/run-command.sh /usr/bin/run-command && \
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
USER        $INSTALLER_USER_NAME
            # region install and configure yay
RUN         pushd /tmp && \
            git clone https://aur.archlinux.org/yay.git && \
            pushd yay && \
            /usr/bin/makepkg --install --needed --noconfirm --syncdeps && \
            popd && \
            rm --force --recursive yay && \
            popd
            # endregion
            # region install "gpgdir"
RUN         yay \
                --needed \
                --noconfirm \
                --sync \
                --noprogressbar \
                gpgdir && \
            sudo rm /var/cache/* --recursive --force
            # endregion
USER        root

RUN         retrieve-application
RUN         env >/etc/default_environment
            # region bootstrap application
RUN         mv /usr/bin/initialize "$INITIALIZING_FILE_PATH" &>/dev/null; \
            chmod +x "$INITIALIZING_FILE_PATH"
# NOTE: "/usr/bin/initialize" (without brackets), "$INITIALIZING_FILE_PATH" or
# ["$INITIALIZING_FILE_PATH"] wont work with command line argument forwarding.
ENTRYPOINT ["/usr/bin/initialize"]
            # endregion
# region modline
# vim: set tabstop=4 shiftwidth=4 expandtab filetype=dockerfile:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
