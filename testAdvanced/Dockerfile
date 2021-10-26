FROM        ghcr.io/thaibault/containerbase
LABEL       maintainer="Torben Sickert <info@torben.website>"
LABEL       Description="proxy" Vendor="thaibault products" Version="1.0"

# Configure runtime user.
USER        root
RUN         configure-user

# Install custom packages (optionally from the arch user repository)
USER        $INSTALLER_USER_NAME
            # NOTE: "neovim" is only needed for debugging scenarios.
RUN         yay \
                --needed \
                --noconfirm \
                --sync \
                neovim && \
            # tidy up
            rm /var/cache/* --recursive --force

# Provide local files at runtime.
RUN         pushd "$(retrieve-application)"

# Enable custom initializer script.
COPY        initialize.sh "$INITIALIZING_FILE_PATH"
