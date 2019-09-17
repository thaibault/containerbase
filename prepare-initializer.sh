#!/usr/bin/bash
# -*- coding: utf-8 -*-
# region choose initializer script
# We prefer the local mounted working copy managed initializer if available.
if [[ "$1" != '--no-check-local-initializer' ]]; then
    for file_path in \
        "${APPLICATION_PATH}serviceHandler/initialize.sh" \
        "${APPLICATION_PATH}initialize.sh"
    do
        if [ -s "$file_path" ]; then
            exec "$file_path" --no-check-local-initializer
        fi
    done
fi
# endregion
# region decrypt security related artefacts needed at runtime
if [[ "$DECRYPT" != false ]]; then
    for index in "${!ENCRYPTED_PATHS[@]}"; do
        if \
            [ -d "${ENCRYPTED_PATHS[index]}" ] && \
            [ -d "${DECRYPTED_PATHS[index]}" ]
        then
            if [ -s "${PASSWORD_FILE_PATHS[index]}" ]; then
                gocryptfs \
                    -allow_other \
                    -nonempty \
                    -passfile "${PASSWORD_FILE_PATHS[index]}" \
                    "${ENCRYPTED_PATH[index]}" \
                    "${DECRYPTED_PATH[index]}"
            else
                gocryptfs \
                    -allow_other \
                    -nonempty \
                    "${ENCRYPTED_PATH[index]}" \
                    "${DECRYPTED_PATH[index]}"
            fi
        fi
    done
fi
# endregion
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
