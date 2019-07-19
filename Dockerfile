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
# - docker pull archlinux/base && docker-compose --file base.yaml build --no-cache
# endregion
# region start container commands
# Run the following command in the directory where this file lives to start:
# - docker-compose --file application.yaml up
# endregion
            # region configuration
FROM        archlinux/base
MAINTAINER  Torben Sickert <info@torben.website>
LABEL       Description="base" Vendor="thaibault products" Version="1.0"
ENV         APPLICATION_PATH /application
ENV         APPLICATION_USER_ID_INDICATOR_FILE_PATH '/application/package.json'
ENV         BRANCH master
ENV         COMMAND 'echo You have to set the \"COMMAND\" environment variale.'
ENV         DEFAULT_MAIN_USER_GROUP_ID 100
ENV         DEFAULT_MAIN_USER_ID 1000
            # NOTE: This value has be in synchronisation with the "CMD" given
            # value.
ENV         INITIALIZING_FILE_PATH '/usr/bin/initialize'
ENV         MAIN_USER_GROUP_NAME users
ENV         MAIN_USER_NAME application
ENV         PRIVATE_SSH_KEY ''
ENV         PUBLIC_SSH_KEY ''
ENV         KNOWN_HOSTS ''
ENV         REPOSITORY_URL 'git@bitbucket.org:tsickert/base.git'
ENV         STANDALONE 'true'
WORKDIR     $APPLICATION_PATH
USER        root
            # endregion
            # region retrieve wget
RUN         sed 's/^#//g' --in-place /etc/pacman.d/mirrorlist && \
            # Update current version to avoid wget compatibility problems
            pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --refresh \
                --sync \
                --sysupgrade && \
            pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --refresh \
                --sync wget && \
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
            # region install and configure yay
            pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --sync \
                base-devel \
                git && \
            # NOTE: We have to patch "makepkg" to use it as root.
            sed \
                --in-place \
                's/if (( EUID == 0 )); then/if (( EUID == 0 )) \&\& false; then/' \
                /usr/bin/makepkg && \
            pushd /tmp && \
            git clone https://aur.archlinux.org/yay.git && \
            pushd yay && \
            makepkg --install --needed --noconfirm --syncdeps && \
            popd && \
            rm --force --recursive yay && \
            popd && \
            # endregion
            # region install needed packages
            # NOTE: "neovim" is only needed for debugging scenarios.
            yay \
                --needed \
                --noconfirm \
                --sync \
                neovim \
                openssh && \
            # tidy up
            rm /var/cache/* --recursive --force
            # endregion
COPY        configure-user.sh /usr/bin/configure-user
COPY        configure-runtime-user.sh /usr/bin/configure-runtime-user
COPY        retrieve-application.sh /usr/bin/retrieve-application
RUN         configure-user
RUN         retrieve-application
RUN         env >/etc/default_environment
            # region set proper user ids and bootstrap application
RUN         echo -e '#!/usr/bin/bash\n\nset -e\nconfigure-runtime-user /' \
                >"$INITIALIZING_FILE_PATH" && \
            chmod +x "$INITIALIZING_FILE_PATH"
CMD         '/usr/bin/initialize'
            # endregion
# region modline
# vim: set tabstop=4 shiftwidth=4 expandtab filetype=dockerfile:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
