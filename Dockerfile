# Run the following command in the directory where this file lives to build a
# new docker image:

# - docker pull finalduty/archlinux && docker-compose --file base.yml build --no-cache

# Run the following command in the directory where this file lives to start:

# - docker-compose --file application.yml up

            # region configuration
FROM        finalduty/archlinux
MAINTAINER  Torben Sickert <info@torben.website>
LABEL       Description="base" Vendor="thaibault products" Version="1.0"
ENV         APPLICATION_PATH /application
ENV         APPLICATION_USER_ID_INDICATOR_FILE_PATH '/application/package.json'
ENV         COMMAND 'start'
ENV         DEFAULT_MAIN_USER_GROUP_ID 100
ENV         DEFAULT_MAIN_USER_ID 1000
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
            pacman --needed --noconfirm --noprogressbar --sync wget && \
            # endregion
            # region get fastest server update list for germany
            url='https://www.archlinux.org/mirrorlist/?country=DE&protocol=http&ip_version=4&use_mirror_status=on' && \
            temporaryFilePath="$(mktemp --suffix=-mirrorlist)" && \
            echo Donwloading latest mirror list. && \
            wget --output-document - "$url" | sed 's/^#Server/Server/g' \
                >"$temporaryFilePath" && \
            echo Backing up the original mirrorlist file. && \
            mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig && \
            echo Rotating the new list into place. && \
            mv "$temporaryFilePath" /etc/pacman.d/mirrorlist && \
            # endregion
            # region adding arch user repository and download database file
            if ! grep '^\[archlinuxfr\]' /etc/pacman.conf &>/dev/null; then echo -n -e '\n[archlinuxfr]\nSigLevel = Optional TrustAll\nServer = http://repo.archlinux.fr/$arch' >>/etc/pacman.conf; fi; \
            pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --refresh \
                --sync \
                --sysupgrade && \
            # endregion
            # region install and configure yaourt
            pacman \
                --needed \
                --noconfirm \
                --noprogressbar \
                --sync \
                base-devel \
                yaourt && \
            # NOTE: We have to patch "makepkg" to use it as root.
            sed \
                --in-place \
                's/if (( EUID == 0 )); then/if (( EUID == 0 )) \&\& false; then/' \
                /usr/bin/makepkg && \
            # endregion
            # region install needed packages
            # NOTE: "neovim" is only needed for debugging scenarios.
            yaourt \
                --needed \
                --noconfirm \
                --sync \
                git \
                openssh \
                neovim && \
            # endregion
            # region tidy up
            rm /var/cache/* --recursive --force
            # endregion
COPY        configure_user.sh /usr/bin/configure-user
COPY        retrieve_application.sh /usr/bin/retrieve-application
            # region set proper user ids and bootstrap application
RUN         echo -e "#!/usr/bin/bash\n\nset -e\nOLD_GROUP_ID=\$(id --group \"\$MAIN_USER_NAME\")\nOLD_USER_ID=\$(id --user \"\$MAIN_USER_NAME\")\nGROUP_ID_CHANGED=false\nif [[ \"\$HOST_GID\" == '' ]]; then\n    HOST_GID=\"\$(stat --format '%g' \"\$APPLICATION_USER_ID_INDICATOR_FILE_PATH\")\"\nfi\nif [[ \$OLD_GROUP_ID != \$HOST_GID ]]; then\n    echo \"Map group id \$OLD_GROUP_ID from application user \$MAIN_USER_NAME to host group id \$HOST_GID from \$(stat --format '%G' \"\$APPLICATION_USER_ID_INDICATOR_FILE_PATH\").\"\n    usermod --gid \"\$HOST_GID\" \"\$MAIN_USER_NAME\"\n    GROUP_ID_CHANGED=true\nfi\nif [[ \"\$HOST_UID\" == '' ]]; then\n    HOST_UID=\"\$(stat --format '%u' \"\$APPLICATION_USER_ID_INDICATOR_FILE_PATH\")\"\nfi\nUSER_ID_CHANGED=false\nif [[ \$OLD_USER_ID != \$HOST_UID ]]; then\n    echo \"Map user id \$OLD_USER_ID from application user \$MAIN_USER_NAME to host user id \$HOST_UID from \$(stat --format '%U' \"\$APPLICATION_USER_ID_INDICATOR_FILE_PATH\").\"\n    usermod --uid \"\$HOST_UID\" \"\$MAIN_USER_NAME\"\n    USER_ID_CHANGED=true\nfi\nif \$GROUP_ID_CHANGED; then\n    find / -xdev -group \$OLD_GROUP_ID -exec chgrp --no-dereference \$MAIN_USER_GROUP_NAME {} \\;\nfi\nif \$USER_ID_CHANGED; then\n    find / -xdev -user \$OLD_USER_ID -exec chown --no-dereference \$MAIN_USER_NAME {} \\;\nfi\nchmod +x /dev/\nchown \$MAIN_USER_NAME:\$MAIN_USER_GROUP_NAME /proc/self/fd/0 /proc/self/fd/1 /proc/self/fd/2\nset +x\ncommand=\"\$(eval \"echo \$COMMAND\")\"\necho Run command \\\"\$command\\\"\nexec su \$MAIN_USER_NAME --group \$MAIN_USER_GROUP_NAME -c \"\$command\"" \
                >"$INITIALIZING_FILE_PATH" && \
            chmod +x "$INITIALIZING_FILE_PATH"
CMD         ["$INITIALIZING_FILE_PATH"]
            # endregion
# region modline
# vim: set tabstop=4 shiftwidth=4 expandtab filetype=dockerfile:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
