#!/usr/bin/bash
# -*- coding: utf-8 -*-
# region convert strings into arrays
ENVIRONMENT_FILE_PATHS=($ENVIRONMENT_FILE_PATHS)
ENVIRONMENT_FILE_PATHS=($ENVIRONMENT_FILE_PATHS)
PASSWORD_FILE_PATHS=($PASSWORD_FILE_PATHS)
# endregion
# region choose initializer script
# We prefer the local mounted working copy managed initializer if available.
if [ "$1" = '--no-check-local-initializer' ]; then
    shift
else
    for file_path in "${ENVIRONMENT_FILE_PATHS[@]}"; do
        file_path="$(dirname "$file_path")/initialize.sh"
        if [ -s "$file_path" ]; then
            exec "$file_path" --no-check-local-initializer "$@"
        fi
    done
fi
# endregion
# region load dynamic environment variables
for file_path in "${ENVIRONMENT_FILE_PATHS[@]}"; do
    if [ -f "$file_path" ]; then
        source "$file_path"
    fi
done
# endregion
# region decrypt security related artefacts needed at runtime
if [[ "$DECRYPT" != false ]]; then
    for index in "${!ENCRYPTED_PATHS[@]}"; do
        if [ -d "${ENCRYPTED_PATHS[index]}" ]; then
            mkdir --parents "${DECRYPTED_PATHS[index]}"
            chown \
                --recursive \
                $MAIN_USER_NAME:$MAIN_USER_GROUP_NAME \
                "${DECRYPTED_PATHS[index]}"
            if [ -s "${PASSWORD_FILE_PATHS[index]}" ]; then
                gocryptfs \
                    -allow_other \
                    -nonempty \
                    -nosyslog \
                    -passfile "${PASSWORD_FILE_PATHS[index]}" \
                    -quiet \
                    "${ENCRYPTED_PATHS[index]}" \
                    "${DECRYPTED_PATHS[index]}"
            elif [ "$1" != '' ]; then
                gocryptfs \
                    -allow_other \
                    -extpass "echo -n '$1'" \
                    -nonempty \
                    -nosyslog \
                    -quiet \
                    "${ENCRYPTED_PATHS[index]}" \
                    "${DECRYPTED_PATHS[index]}"
            else
                gocryptfs \
                    -allow_other \
                    -nonempty \
                    -nosyslog \
                    -quiet \
                    "${ENCRYPTED_PATHS[index]}" \
                    "${DECRYPTED_PATHS[index]}"
            fi
        fi
    done
fi
# endregion
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
