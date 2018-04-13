# Run the following command in the directory where this file lives to build a
# new docker image:

# - docker pull finalduty/archlinux && docker-compose --file base.yml build --no-cache

# Run the following command in the directory where this file lives to start:

# - docker-compose --file application.yml up

            # region configuration
FROM        finalduty/archlinux
MAINTAINER  Torben Sickert <info@torben.website>
LABEL       Description="base" Vendor="thaibault products" Version="1.0"
#EXPOSE      80 443
ENV         APPLICATION_PATH /root
ENV         APPLICATION_USER_ID_INDICATOR_FILE_PATH '/usr/bin/env'
            ## region Application specific configuration
            ## endregion
ENV         DEFAULT_MAIN_USER_GROUP_ID 0
ENV         DEFAULT_MAIN_USER_ID 0
ENV         INITIALIZING_FILE_PATH '/usr/bin/initialize'
ENV         MAIN_USER_GROUP_NAME root
ENV         MAIN_USER_NAME root
ENV         PRIVATE_SSH_KEY ''
ENV         PUBLIC_SSH_KEY 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjd2HXYtP81bH7Rs8PJkO5lzoS2VTPnPg6f5wWruciPg/h9B+MyM+5i4fo/qzNkfI+JXjzsYpqGZf64WCj50HI+IfVQtj7EMT9w1oPWn5eDmqPDuZ+N+SUjd67wzTBiHWciEjJwrY3xvU6UnvndwULdYB2DcK+VEeHlBlXqEQ6FzG4RlTOTlMZa0EZdW2WcwZlcqwgEyexGYmB+0bhJ1TtXY77VmIOLh4+bNNRSHBCOJ3INtOBoiJck81BWlD95qR9dEMuFxQQT1fula3BVPKZfsQKm6eN34Jal8M6DyWI0zubrN3MQZuBb940VnryD68KAz6ELTwaYzxqBJPMijH/ webAPP'
ENV         KNOWN_HOSTS 'bitbucket.org,131.103.20.167 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAubiN81eDcafrgMeLzaFPsw2kNvEcqTKl/VqLat/MaB33pZy0y3rJZtnqwR2qOOvbwKZYKiEO1O6VqNEBxKvJJelCq0dTXWT5pbO2gDXC6h6QDXCaHo6pOHGPUy+YBaGQRGuSusMEASYiWunYN0vCAI8QaXnWMXNMdFP3jHAJH0eDsoiGnLPBlBp4TNm6rYI74nMzgz3B9IikW4WVK+dc8KZJZWYjAuORU3jc1c/NPskD2ASinf8v3xnfXeukU0sJ5N6m5E8VLjObPEO+mN2t/FZTMZLiFqPWc/ALSqnMnnhwrNi2rbfg/rd/IpL8Le3pSBne8+seeFVBoGqzHM9yXw=='
ENV         REPOSITORY_URL 'git@bitbucket.org:tsickert/base.git'
WORKDIR     $APPLICATION_PATH
USER        root
            # endregion
            # region retrieve wget
RUN         sed 's/^#//g' --in-place /etc/pacman.d/mirrorlist && \
            pacman --needed --nocon firm --noprogressbar --sync wget && \
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
            sed --in-place \
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
                neovim && \
            # endregion
            # region tidy up
            rm /var/cache/* --recursive --force
            # endregion
            # region preconfigure application user
            # Set proper default user and group id to avoid expendsive user id
            # mapping on application startup.
RUN         [[ "$MAIN_USER_NAME" != root ]] && \
            groupmod --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                "$MAIN_USER_GROUP_NAME" && \
            usermod --gid "$DEFAULT_MAIN_USER_GROUP_ID" --uid \
                "$DEFAULT_MAIN_USER_ID" "$MAIN_USER_NAME" && \
            chown --recursive "${MAIN_USER_NAME}:${MAIN_USER_GROUP_NAME}" \
                "$(pwd)" && \
            echo /usr/bin/bash>>/etc/shells && \
            chsh --shell /usr/bin/bash "$MAIN_USER_NAME" && \
            usermod --home "$(pwd)" "$MAIN_USER_NAME" || \
            true
            # endregion
            # region configure and integrate current application
# NOTE: Current version of the application will be live in the image. For
# development scenarios we can simply mount our working copy over the
# application root.
RUN         touch "$INITIALIZING_FILE_PATH" && \
            chown "${MAIN_USER_NAME}:${MAIN_USER_GROUP_NAME}" \
                "$INITIALIZING_FILE_PATH"
RUN         [ "$STANDALONE" = true ] && \
            [[ "$PRIVATE_SSH_KEY" != '' ]] && \
            [[ "$PUBLIC_SSH_KEY" != '' ]] && \
            [[ "$REPOSITORY_URL" != '' ]] && \
            cd && \
            mkdir --parents .ssh && \
            echo -e "$PRIVATE_SSH_KEY" >.ssh/id_rsa && \
            chmod 600 .ssh/id_rsa && \
            echo -e "$PUBLIC_SSH_KEY" >.ssh/id_rsa.pub && \
            chmod 600 .ssh/id_rsa.pub && \
            echo -e "$KNOWN_HOSTS" >.ssh/known_hosts && \
            chmod 600 .ssh/known_hosts && \
            git clone --depth 1 --no-single-branch "$REPOSITORY_URL" \
                "$APPLICATION_PATH" && \
            cd "$APPLICATION_PATH" && \
            git submodule init && \
            git submodule foreach \
                'branch="$(git config --file "$toplevel/.gitmodules" "submodule.$name.branch")";git clone --depth 1 --branch "$branch"' && \
            git submodule update --remote && \
            rm --recursive --force .git && \
            chown "${MAIN_USER_NAME}:${MAIN_USER_GROUP_NAME}" \
                "$APPLICATION_PATH" || \
            true
            # endregion
            # region set proper user ids and bootstrap application
RUN         echo -e "#!/usr/bin/bash\n\nset -e\nOLD_GROUP_ID=\$(id --group \"\$MAIN_USER_NAME\")\nOLD_USER_ID=\$(id --user \"\$MAIN_USER_NAME\")\nGROUP_ID_CHANGED=false\nif [[ \"\$HOST_GID\" == '' ]]; then\n    HOST_GID=\"\$(stat --format '%g' \"\$APPLICATION_USER_ID_INDICATOR_FILE_PATH\")\"\nfi\nif [[ \$OLD_GROUP_ID != \$HOST_GID ]]; then\n    echo \"Map group id \$OLD_GROUP_ID from application user \$MAIN_USER_NAME to host group id \$HOST_GID from \$(stat --format '%G' \"\$APPLICATION_USER_ID_INDICATOR_FILE_PATH\").\"\n    usermod --gid \"\$HOST_GID\" \"\$MAIN_USER_NAME\"\n    GROUP_ID_CHANGED=true\nfi\nif [[ \"\$HOST_UID\" == '' ]]; then\n    HOST_UID=\"\$(stat --format '%u' \"\$APPLICATION_USER_ID_INDICATOR_FILE_PATH\")\"\nfi\nUSER_ID_CHANGED=false\nif [[ \$OLD_USER_ID != \$HOST_UID ]]; then\n    echo \"Map user id \$OLD_USER_ID from application user \$MAIN_USER_NAME to host user id \$HOST_UID from \$(stat --format '%U' \"\$APPLICATION_USER_ID_INDICATOR_FILE_PATH\").\"\n    usermod --uid \"\$HOST_UID\" \"\$MAIN_USER_NAME\"\n    USER_ID_CHANGED=true\nfi\nif \$GROUP_ID_CHANGED; then\n    find / -xdev -group \$OLD_GROUP_ID -exec chgrp --no-dereference \$MAIN_USER_GROUP_NAME {} \\;\nfi\nif \$USER_ID_CHANGED; then\n    find / -xdev -user \$OLD_USER_ID -exec chown --no-dereference \$MAIN_USER_NAME {} \\;\nfi\nchmod +x /dev/\nchown \$MAIN_USER_NAME:\$MAIN_USER_GROUP_NAME /proc/self/fd/0 /proc/self/fd/1 /proc/self/fd/2\nset +x\ncommand=\"\$(eval \"echo \$COMMAND\")\"\necho Run command \\\"\$command\\\"\nexec su \$MAIN_USER_NAME --group \$MAIN_USER_GROUP_NAME -c \"\$command\"" \
                >"$INITIALIZING_FILE_PATH" && \
            chmod +x "$INITIALIZING_FILE_PATH"
CMD         [/usr/bin/initialize]
            # endregion
# region modline
# vim: set tabstop=4 shiftwidth=4 expandtab filetype=dockerfile:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
