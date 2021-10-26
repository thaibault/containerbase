FROM        ghcr.io/thaibault/containerbase

LABEL       maintainer="Torben Sickert <info@torben.website>"
LABEL       Description="proxy" Vendor="thaibault products" Version="1.0"

ENV         COMMAND 'echo Application started. Decrypted content at \\\"\${DECRYPTED_PATH}/secret.txt\\\" is \\\"\$\(cat \\\"\${DECRYPTED_PATH}/secret.txt\\\"\)\\\".'

ENV         MAIN_USER_NAME application

WORKDIR     $APPLICATION_PATH

USER        root

# TODO
COPY        ./decrypt.sh /usr/bin/decrypt

COPY        ./encrypted ./encrypted
COPY        ./environment.sh ./etc/containerBase/environment.sh
