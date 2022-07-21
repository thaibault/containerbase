FROM        ghcr.io/thaibault/containerbase:latest-x86-64

LABEL       maintainer="Torben Sickert <info@torben.website>"
LABEL       Description="proxy" Vendor="thaibault products" Version="1.0"

ENV         COMMAND 'echo Application started. Decrypted content at \\\"\${DECRYPTED_PATHS}secret.txt\\\" is \\\"\$\(cat \"\${DECRYPTED_PATHS}secret.txt\"\)\\\".'

ENV         MAIN_USER_NAME application

WORKDIR     $APPLICATION_PATH

COPY        ./encrypted ./encrypted
COPY        ./environment.sh /etc/containerBase/environment.sh
