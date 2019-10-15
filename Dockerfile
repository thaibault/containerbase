# region header
# [Project page](https://torben.website/dockerbase)

# Copyright Torben Sickert (info["~at~"]torben.website) 16.12.2012

# License
# -------

# This library written by Torben Sickert stand under a creative commons naming
# 3.0 unported license.
# See https://creativecommons.org/licenses/by/3.0/deed.de
# endregion
# region create image commands
# Run the following command in the directory where this file lives to build a
# new docker image:
# - podman pull archlinux/base && podman build --file Dockerfile --no-cache
# endregion
# region start container commands
# Run the following command in the directory where this file lives to start:
# - docker-compose --file application.yaml up
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
ENV         ENVIRONMENT_FILE_PATHS "/etc/dockerBase/environment.sh ${APPLICATION_PATH}serviceHandler/environment.sh ${APPLICATION_PATH}environment.sh"
            # NOTE: This value has be in synchronisation with the "CMD" given
            # value.
ENV         INITIALIZING_FILE_PATH /usr/bin/initialize
ENV         INSTALLER_USER_NAME installer
ENV         MAIN_USER_GROUP_NAME users
ENV         MAIN_USER_NAME application
ENV         PASSWORD_FILE_PATHS "${APPLICATION_PATH}.encryptionPassword"
ENV         PRIVATE_SSH_KEY ''
ENV         PUBLIC_SSH_KEY ''
ENV         KNOWN_HOSTS ''
ENV         REPOSITORY_URL 'git@bitbucket.org:tsickert/base.git'
ENV         STANDALONE true
WORKDIR     $APPLICATION_PATH
USER        root
            # endregion
            # region retrieve wget
RUN         sed 's/^#//g' --in-place /etc/pacman.d/mirrorlist && \
            # Update package database first to retreive newest wget version
            # Update pacman keys
            #pacman-key --init && \
            #pacman-key --populate archlinux && \
            pacman-key --refresh-keys && \
            pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --refresh \
                --sync \
                base && \
            pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --refresh \
                --sync \
                --sysupgrade && \
            # NOTE: We should avoid leaving unnecessary data in that layer.
            rm --force --recursive /etc/pacman.d/gnupg
RUN         pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --refresh \
                --sync \
                wget && \
            # NOTE: We should avoid leaving unnecessary data in that layer.
            rm /var/cache/* --recursive --force && \
            # endregion
            # region get fastest server update list for germany
            url='https://www.archlinux.org/mirrorlist/?country=DE&protocol=http&ip_version=4&use_mirror_status=on' && \
            temporaryFilePath="$(mktemp --suffix=-mirrorlist)" && \
            echo Donwloading latest mirror list. && \
            wget --output-document - "$url" | \
                sed 's/^#Server/Server/g' \
                    >"$temporaryFilePath" && \
            echo Backing up the original mirrorlist file. && \
            mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig && \
            echo Rotating the new list into place. && \
            mv "$temporaryFilePath" /etc/pacman.d/mirrorlist && \
            chmod +r /etc/pacman.d/mirrorlist && \
            # endregion
            # region update system with refreshed mirrorlist
            pacman \
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
COPY        configure-user.sh /usr/bin/configure-user
COPY        configure-runtime-user.sh /usr/bin/configure-runtime-user
COPY        retrieve-application.sh /usr/bin/retrieve-application
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
            mkdir --parents /etc/dockerBase
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
COPY        prepare-initializer.sh /usr/bin/prepare-initializer
RUN         echo -e '#!/usr/bin/bash\n\nprepare-initializer && \\\nset -e\nconfigure-runtime-user /' \
                >"$INITIALIZING_FILE_PATH" && \
            chmod +x "$INITIALIZING_FILE_PATH"
CMD         /usr/bin/initialize
            # endregion
# region modline
# vim: set tabstop=4 shiftwidth=4 expandtab filetype=dockerfile:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
