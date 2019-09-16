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
if \
    [[ "$DECRYPT" != false ]] && \
    [ -d "$ENCRYPTED_PATH" ] && \
    [ -d "$DECRYPTED_PATH" ]
then
    if [ -s "$PASSWORD_FILE_PATH" ]; then
        gocryptfs \
            -allow_other \
            -passfile "$PASSWORD_FILE_PATH" \
            "$ENCRYPTED_PATH" \
            "$DECRYPTED_PATH"
    else
        gocryptfs -allow_other "$ENCRYPTED_PATH" "$DECRYPTED_PATH"
    fi
fi
# endregion
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
