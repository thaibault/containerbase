FROM        ghcr.io/thaibault/containerbase
LABEL       maintainer="Torben Sickert <info@torben.website>"
LABEL       Description="test" Vendor="thaibault products" Version="1.0"

ENV         COMMAND 'echo Application started: Test content of encrypted folder \"$ENCRYPTED_PATHS\" located at \"$DECRYPTED_PATHS\". Example file content of \"${DECRYPTED_PATHS}secret-configuration.txt\" is "$(cat "${DECRYPTED_PATHS}secret-configuration.txt")".'
