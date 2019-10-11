#!/usr/bin/bash
# -*- coding: utf-8 -*-
# region convert environment variables given as string into local arrays
for name in \
    DECRYPTED_PATHS \
    ENCRYPTED_PATHS \
    ENVIRONMENT_FILE_PATHS \
    PASSWORD_FILE_PATHS
do
    if ! [[ "$(declare -p "$name" 2>/dev/null)" =~ 'declare -a' ]]; then
        eval "declare -a ${name}_ARRAY=(\$${name})"
    fi
done
# endregion
# region choose initializer script
# We prefer the local mounted working copy managed initializer if available.
if [ "$1" = '--no-check-local-initializer' ]; then
    shift
else
    # Reverse list of paths.
    reversed_environment_file_paths=()
    for file_path in "${ENVIRONMENT_FILE_PATHS_ARRAY[@]}"; do
        if [ "${#reversed_environment_file_paths[@]}" = 0 ]; then
            reversed_environment_file_paths=("$file_path")
        else
            reversed_environment_file_paths=("$file_path" "${reversed_environment_file_paths[@]}")
        fi
    done
    for file_path in "${reversed_environment_file_paths[@]}"; do
        file_path="$(dirname "$file_path")/initialize.sh"
        if [ -s "$file_path" ]; then
            exec "$file_path" --no-check-local-initializer "$@"
        fi
    done
fi
# endregion
# region load dynamic environment variables
for file_path in "${ENVIRONMENT_FILE_PATHS_ARRAY[@]}"; do
    if [ -f "$file_path" ]; then
        source "$file_path"
    fi
done
# endregion
# region decrypt security related artefacts needed at runtime
if [[ "$DECRYPT" != false ]]; then
    for index in "${!ENCRYPTED_PATHS_ARRAY[@]}"; do
        if [ -d "${ENCRYPTED_PATHS[index]}" ]; then
            mkdir --parents "${DECRYPTED_PATHS[index]}"
            chown \
                --recursive \
                $MAIN_USER_NAME:$MAIN_USER_GROUP_NAME \
                "${DECRYPTED_PATHS[index]}"
            if [ -s "${PASSWORD_FILE_PATHS[index]}" ]; then
                cp ${PASSWORD_FILE_PATHS[index]} /tmp/intermediatePasswordFile
            elif [[ "$1" != '' ]]; then
                echo -n "$1" >/tmp/intermediatePasswordFile
            fi
            if [ -s /tmp/intermediatePasswordFile ]; then
                gocryptfs \
                    -allow_other \
                    -nonempty \
                    -nosyslog \
                    -passfile /tmp/intermediatePasswordFile \
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
