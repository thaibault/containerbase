FROM        ghcr.io/thaibault/containerbase
LABEL       maintainer="Torben Sickert <info@torben.website>"
LABEL       Description="proxy" Vendor="thaibault products" Version="1.0"

ENV         MAIN_USER_NAME application

# Install custom packages (optionally from the arch user repository)
USER        $INSTALLER_USER_NAME
            # NOTE: "neovim" is only needed for debugging scenarios.
RUN         yay \
                --needed \
                --noconfirm \
                --sync \
                tree && \
            # tidy up
            rm /var/cache/* --recursive --force
USER        root

# Configure runtime user.
RUN         configure-user

# Provide local files at runtime.
RUN         pushd "$(retrieve-application)"

# Enable custom initializer script.
COPY        initialize.sh "$INITIALIZING_FILE_PATH"
