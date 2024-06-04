# syntax=docker/dockerfile-upstream:master-labs
# region header
# [Project page](https://torben.website/containerbase)

# Copyright Torben Sickert (info["~at~"]torben.website) 16.12.2012

# License
# -------

# This library written by Torben Sickert stand under a creative commons naming
# 4.0 unported license.
# See https://creativecommons.org/licenses/by/3.0/deed.de

# Basic ArchLinux with user-mapping, AUR integration and support for decryption
# of security related files.
# endregion
# region create commands
# Run the following command in the directory where this file lives to build a
# new docker image:

# x86-64 only with remote base image

# - docker buildx build --build-arg BASE_IMAGE='' --build-arg MULTI='' --build-arg MIRROR_AREA_PATTERN='United States' --no-cache --tag ghcr.io/thaibault/containerbase:latest .

# Multi architecture

# - podman build --file https://raw.githubusercontent.com/thaibault/containerbase/main/Dockerfile --no-cache --tag ghcr.io/thaibault/containerbase:latest .
# - docker buildx build --no-cache --tag ghcr.io/thaibault/containerbase:latest .
# endregion
# region start container commands
# Run the following command in the directory where this file lives to start:
# - podman pod rm --force base_pod; podman play kube kubernetes.yaml
# - docker rm --force base; docker compose up
# endregion
# region bootstrapping
            # NOTE: Just remove default value "base" to use remote image.
ARG         BASE_IMAGE=base
            # NOTE: Disabling "BUILD_ARM_FROM_ARCHIVE" via "--build-arg
            # BUILD_ARM_FROM_ARCHIVE=''" will use alpine's arm pacman to
            # bootstrap arch linux root files.
ARG         BUILD_ARM_FROM_ARCHIVE=true
            # NOTE: Disabling "MULTI" via "--build-arg MULTI=''" will use
            # pre-build arch images which may have deprecated packages to
            # update included.
ARG         MULTI=true
ARG         MIRROR_AREA_PATTERN='default'

FROM        alpine AS bootstrapper
ARG         BUILD_ARM_FROM_ARCHIVE
ARG         TARGETARCH
            # To be able to download "ca-certificates" with "apk add" command we
            # we need to manually add the certificate in the first place.
            # Afterwards we update with the official tool
            # "update-ca-certificates".
            # NOTE: We need to copy .gitignore to workaround an unavailable
            # copy certificate file if it exists mechanism.
COPY        .gitignore custom-root-ca.cr[t] /root/
            # NOTE: "*.cer" files can be converted into "*.crt" via:
            # openssl x509 -inform der -in source.cer -out target.crt
RUN \
            rm /root/.gitignore && \
            if [ -f /root/custom-root-ca.crt ]; then \
                cat /root/custom-root-ca.crt >> /etc/ssl/certs/ca-certificates.crt && \
                apk add --no-cache --no-check-certificate ca-certificates && \
                rm -rf /var/cache/apk/* && \
                mv /root/custom-root-ca.crt /usr/local/share/ca-certificates/ && \
                update-ca-certificates; \
            fi
## region bootstrap from file system archive
RUN \
            if \
                [ "$BUILD_ARM_FROM_ARCHIVE" = true ] && \
                [ "$BASE_IMAGE" = '' ] && \
                [[ "$TARGETARCH" == 'arm*' ]]; \
            then \
                apk add curl && \
                mkdir --parents /rootfs && \
                curl \
                    --connect-timeout 30 \
                    --fail \
                    --location \
                    --retry 3 \
                    'http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz' | \
                        tar \
                            --directory /rootfs/ \
                            --extract \
                            --gzip \
                            --verbose; \
            fi
## endregion
## region bootstrap via pacman
RUN \
            if [ "$BASE_IMAGE" = '' ]; then \
                apk add arch-install-scripts curl pacman-makepkg && \
                mkdir --parents /etc/pacman.d /tmp/keyring; \
            fi \
COPY        --link ./pacman-conf.d-noextract.conf /etc/pacmand.d/noextract.conf
RUN \
            if [ "$BASE_IMAGE" = '' ] && [[ "$TARGETARCH" == 'arm*' ]]; then \
                sed \
                    --in-place \
                    --regexp-extended \
                    's/^(Architecture = +)[^ ]+$/\1aarch64/' \
                    /etc/pacman.conf && \
                REPOSITORY=archlinuxarm && \
                KEYRING_PACKAGE_URL="http://mirror.archlinuxarm.org/aarch64/core/${REPOSITORY}-keyring-20240419-1-any.pkg.tar.xz" && \
                echo -e '\n\
[core]\n\
Include = /etc/pacman.d/mirrorlist\n\
[extra]\n\
Include = /etc/pacman.d/mirrorlist\n\
[community]\n\
Include = /etc/pacman.d/mirrorlist\n\
[alarm]\n\
Include = /etc/pacman.d/mirrorlist\n\
[aur]\n\
Include = /etc/pacman.d/mirrorlist' \
                    >> /etc/pacman.conf && \
                echo \
                    'Server = http://mirror.archlinuxarm.org/$arch/$repo' \
                    > /etc/pacman.d/mirrorlist; \
            elif [ "$BASE_IMAGE" = '' ] && [[ "$TARGETARCH" != 'arm*' ]]; then \
                REPOSITORY=archlinux && \
                KEYRING_PACKAGE_URL="https://archlinux.org/packages/core/any/${REPOSITORY}-keyring/download" && \
                echo -e '\n\
[core]\n\
Include = /etc/pacman.d/mirrorlist\n\
[extra]\n\
Include = /etc/pacman.d/mirrorlist\n\
[community]\n\
Include = /etc/pacman.d/mirrorlist' \
                    >> /etc/pacman.conf && \
                echo \
                    'Server = http://mirrors.xtom.com/archlinux/$repo/os/$arch' \
                    > /etc/pacman.d/mirrorlist; \
            fi && \
            if \
                [ "$BUILD_ARM_FROM_ARCHIVE" = '' ] && \
                [ "$BASE_IMAGE" = '' ] && \
                [[ "$TARGETARCH" == 'arm*' ]]; \
            then \
                curl \
                    --connect-timeout 30 \
                    --fail \
                    --location \
                    --retry 3 \
                    "$KEYRING_PACKAGE_URL" | \
                        tar \
                            --directory /tmp/keyring \
                            --extract \
                            --xz \
                            --verbose; \
            elif [ "$BASE_IMAGE" = '' ] && [[ "$TARGETARCH" != 'arm*' ]]; then \
                apk add zstd && \
                curl \
                    --connect-timeout 30 \
                    --fail \
                    --location \
                    --retry 3 \
                    "$KEYRING_PACKAGE_URL" | \
                        unzstd | \
                            tar \
                                --directory /tmp/keyring \
                                --extract \
                                --verbose; \
            fi && \
            if [ -d /tmp/keyring/usr/share/pacman/keyrings ]; then \
                mv \
                    /tmp/keyring/usr/share/pacman/keyrings \
                    /usr/share/pacman/ && \
                rm --force --recursive /etc/pacman.d/gnupg /var/lib/pacman/sync && \
                pacman-key --init && \
                pacman-key --populate && \
                mkdir \
                    --mode 0755 \
                    --parents \
                        /rootfs/var/cache/pacman/pkg \
                        /rootfs/var/lib/pacman \
                        /rootfs/var/log \
                        /rootfs/dev \
                        /rootfs/run \
                        /rootfs/etc && \
                mkdir --mode 1777 --parents /rootfs/tmp && \
                mkdir \
                    --mode 0555 \
                    --parents \
                        /rootfs/sys \
                        /rootfs/proc && \
                mknod /rootfs/dev/null c 1 3 && \
                pacman \
                    --refresh \
                    --root /rootfs \
                    --sync \
                    --noconfirm \
                    --noprogressbar \
                    base "${REPOSITORY}-keyring" && \
                rm /rootfs/dev/null && \
                cp --force /etc/pacman.conf /rootfs/etc/ && \
                cp --force /etc/pacman.d/mirrorlist /rootfs/etc/pacman.d/; \
            fi && \
            rm --force --recursive \
                /rootfs/README \
                /rootfs/var/cache/pacman/pkg/* \
                /rootfs/var/lib/pacman/sync \
                /rootfs/usr/share/doc/* \
                /rootfs/usr/share/gtk-doc/html/* \
                /rootfs/usr/share/info/* \
                /rootfs/usr/share/man/*
## endregion
# endregion
# region install and update packages
FROM        scratch AS root
ARG         MIRROR_AREA_PATTERN
COPY        --from=bootstrapper /rootfs/ /
COPY        --link ./scripts/clean-up.sh /usr/bin/clean-up
COPY        --link ./pacman-conf.d-noextract.conf /etc/pacmand.d/noextract.conf
RUN \
            rm --force --recursive /etc/pacman.d/gnupg && \
            pacman-key --init && \
            pacman-key --populate
## region install needed base packages
            # NOTE: openssl-1.1 is needed by arm pacman but not provided per
            # default.
RUN \
            pacman \
                --noconfirm \
                --noprogressbar \
                --refresh \
                --sync \
                base \
                openssl-1.1 \
                nawk && \
            clean-up
            # Update mirrorlist if existing
RUN \
            if [[ "$MIRROR_AREA_PATTERN" != default ]]; then \
                if [ -f /etc/pacman.d/mirrorlist.pacnew ]; then \
                    mv \
                        /etc/pacman.d/mirrorlist.pacnew \
                        /etc/pacman.d/mirrorlist \
                        &>/dev/null; \
                fi && \
                cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig && \
                awk \
                    '/^## '"${MIRROR_AREA_PATTERN}"'$/{f=1}f==0{next}/^$/{exit}{print substr($0, 2)}' \
                    /etc/pacman.d/mirrorlist.orig \
                    >/etc/pacman.d/mirrorlist; \
            fi
            # Update package database to retrieve newest package versions
RUN \
            clean-up \
                nawk \
                nano \
                netctl \
                net-tools \
                vi && \
            pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --refresh \
                --sync \
                --sysupgrade && \
            clean-up && \
            # Configure locale.
            sed \
                --regexp-extended \
                --expression 's/#(en_US.UTF-8 UTF-8)/\1/' \
                --in-place \
                /etc/locale.gen && \
            locale-gen && \
## endregion
## region install needed packages
            # NOTE: "neovim" is needed for debugging scenarios.
            # NOTE: "openssh" to retrieve files securely e.g. via git.
            pacman \
                --needed \
                --noconfirm \
                --sync \
                --noprogressbar \
                neovim \
                openssh && \
            clean-up
## endregion
## region install packages to build other packages
RUN \
            pacman \
                --disable-download-timeout \
                --needed \
                --noconfirm \
                --noprogressbar \
                --sync \
                base-devel \
                git && \
            clean-up && \
            mkdir --parents /etc/containerBase
## endregion
# endregion
# region configuration
FROM        scratch AS base
COPY        --from=root / /
RUN         ln --force --symbolic /usr/lib/os-release /etc/os-release
## region configuration
FROM        ${BASE_IMAGE:-${MULTI:+'menci/'}archlinux${MULTI:+'arm'}}

LABEL       org.opencontainers.image.title='Multi-Architecture Arch Linux base Image'
LABEL       org.opencontainers.image.description='Multi-Architecture unofficial containerd image of Arch Linux, a simple, lightweight Linux distribution aimed for flexibility with some utility helpers included.'
LABEL       org.opencontainers.image.authors='Torben Sickert <info@torben.website> (@thaibault)'
LABEL       org.opencontainers.image.url=https://github.com/thaibault/containerbase/pkgs/container/containerbase
LABEL       org.opencontainers.image.documentation=https://github.com/thaibault/containerbase/blob/main/readme.md
LABEL       org.opencontainers.image.source=https://github.com/thaibault/containerbase
LABEL       org.opencontainers.image.licenses=CC-4.0
LABEL       org.opencontainers.image.version=0.0.1

ENV         APPLICATION_PATH=/application/
ENV         ENVIRONMENT_FILE_PATHS="/etc/containerBase/environment.sh ${APPLICATION_PATH}serviceHandler/environment.sh ${APPLICATION_PATH}environment.sh"

ENV         COMMAND='echo "echo You have to set the \"COMMAND\" environment variable."'
            # NOTE: This value has be in synchronisation with the "CMD" given
            # value.
ENV         INITIALIZING_FILE_PATH=/usr/bin/initialize

ENV         DECRYPT=false
ENV         DECRYPT_AS_USER=true
ENV         DECRYPTED_PATHS=/tmp/plain/
ENV         ENCRYPTED_PATHS="${APPLICATION_PATH}encrypted/"
ENV         PASSWORD_SECRET_NAMES=encryption_password
ENV         PASSWORD_FILE_PATHS="${APPLICATION_PATH}.encryptionPassword"

ENV         APPLICATION_USER_ID_INDICATOR_FILE_PATH=/application/package.json
ENV         DEFAULT_MAIN_USER_GROUP_ID=100
ENV         DEFAULT_MAIN_USER_ID=1000
ENV         INSTALLER_USER_NAME=installer
ENV         MAIN_USER_GROUP_NAME=users
ENV         MAIN_USER_NAME=application

ENV         KNOWN_HOSTS=''

ENV         PRIVATE_SSH_KEY=''
ENV         PUBLIC_SSH_KEY=''
            # git@github.com:thaibault/containerbase
ENV         REPOSITORY_URL=https://github.com/thaibault/containerbase.git
            # NOTE: Do not set as environment variable to avoid shadowing this
            # argument in inherited image builds.
ARG         BRANCH_NAME

ENV         STANDALONE=true

ENV         LANG=en_US.UTF-8

WORKDIR     $APPLICATION_PATH

USER        root
## endregion
## region retrieve artefacts
COPY        --link ./scripts/clean-up.sh /usr/bin/clean-up
COPY        --link ./scripts/configure-runtime-user.sh /usr/bin/configure-runtime-user
COPY        --link ./scripts/configure-user.sh /usr/bin/configure-user
COPY        --link ./scripts/crypt.sh /usr/bin/crypt
COPY        --link ./scripts/decrypt.sh /usr/bin/decrypt
COPY        --link ./scripts/encrypt.sh /usr/bin/encrypt
COPY        --link ./scripts/initialize.sh /usr/bin/initialize
COPY        --link ./scripts/prepare-initializer.sh /usr/bin/prepare-initializer
COPY        --link ./scripts/retrieve-application.sh /usr/bin/retrieve-application
COPY        --link ./scripts/execute-command.sh /usr/bin/execute-command
COPY        --link ./scripts/run-command.sh /usr/bin/run-command
## endregion
## region configure user
RUN \
            configure-user && \
            # We cannot use yay as root user so we introduce an install user.
            # Create specified user with not yet existing name and id.
            # NOTE: Use exotic user id reduce risk of id clashing when mapping
            # to hosts user id at runtime.
            useradd \
                --create-home \
                --no-user-group \
                "${INSTALLER_USER_NAME}" \
                --uid 7777 && \
            echo \
                -e \
                "\n\n%users ALL=(ALL) ALL\n${INSTALLER_USER_NAME} ALL=(ALL) NOPASSWD:/usr/bin/pacman,/usr/bin/rm" \
                >>/etc/sudoers
## endregion
USER        $INSTALLER_USER_NAME
## region install and configure yay
RUN \
            pushd /tmp && \
            git clone https://aur.archlinux.org/yay.git && \
            pushd yay && \
            /usr/bin/makepkg \
                --install \
                --needed \
                --noconfirm \
                --rmdeps \
                --syncdeps && \
            popd && \
            rm --force --recursive yay && \
            popd && \
            rm --force --recursive ~/.cache/go-build && \
            clean-up
## endregion
USER        root

RUN         retrieve-application
RUN         env >/etc/default_environment
## region bootstrap application
RUN \
            mv /usr/bin/initialize "$INITIALIZING_FILE_PATH" &>/dev/null; \
            chmod +x "$INITIALIZING_FILE_PATH"
# NOTE: "/usr/bin/initialize" (without brackets), "$INITIALIZING_FILE_PATH" or
# ["$INITIALIZING_FILE_PATH"] wont work with command line argument forwarding.
ENTRYPOINT  ["/usr/bin/initialize"]
## endregion
# endregion
# region modline
# vim: set tabstop=4 shiftwidth=4 expandtab filetype=dockerfile:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
