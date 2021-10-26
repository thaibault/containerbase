FROM        ghcr.io/thaibault/containerbase
LABEL       maintainer="Torben Sickert <info@torben.website>"
LABEL       Description="proxy" Vendor="thaibault products" Version="1.0"

ENV         COMMAND nginx

USER        root
RUN         configure-user

USER        $INSTALLER_USER_NAME
            # NOTE: "neovim" is only needed for debugging scenarios.
RUN         yay \
                --needed \
                --noconfirm \
                --sync \
                neovim && \
            # tidy up
            rm /var/cache/* --recursive --force
            # endregion
RUN         pushd "$(retrieve-application)"

USER        root
COPY        initialize.sh "$INITIALIZING_FILE_PATH"
