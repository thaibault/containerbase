#!/usr/bin/bash
# -*- coding: utf-8 -*-
# region header
# [Project page](https://torben.website/containerbase)

# Copyright Torben Sickert (info["~at~"]torben.website) 16.12.2012

# License
# -------

# This library written by Torben Sickert stand under a creative commons naming
# 3.0 unported license.
# See https://creativecommons.org/licenses/by/3.0/deed.de
# endregion
# shellcheck disable=SC2016,SC2034,SC2155
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
# region load dynamic environment variables
for file_path in "${ENVIRONMENT_FILE_PATHS_ARRAY[@]}"; do
    if [ -f "$file_path" ]; then
        source "$file_path"
    fi
done
# endregion
# region determine decrypter
# determine gpgdir binary location
for decrypter in \
    /tmp/gpgdir \
    /usr/bin/gpgdir \
    /usr/bin/perlbin/site_perl/gpgdir \
    /tmp/gpgdir-nodeps-*/gpgdir
do
    if [ -f "$decrypter" ]; then
        break
    fi
done
raw_decrypt() {
    local password_file_parameter=''
    if [[ "$2" != '' ]]; then
        password_file_parameter="--pw-file '$2'"
    fi

    "$decrypter" \
        --decrypt "$1" \
        --overwrite-decrypted \
        --Symmetric \
        --quiet \
        "$password_file_parameter"

    return $?
}
decrypt() {
    if (( HOST_USER_ID == 0 )); then
        raw_decrypt "$@"
    else
        su "$MAIN_USER_NAME" --group "$MAIN_USER_GROUP_NAME" -c "raw_decrypt $@"
    fi
}
# endregion
# region decrypt security related  artefacts needed at runtime
if [[ "$DECRYPT" != false ]]; then
    for index in "${!ENCRYPTED_PATHS_ARRAY[@]}"; do
        if [ -d "${ENCRYPTED_PATHS_ARRAY[index]}" ]; then
            rm \
                --force \
                --recursive \
                "${DECRYPTED_PATHS_ARRAY[index]}" \
                &>/dev/null
            mkdir --parents "${DECRYPTED_PATHS_ARRAY[index]}"
            chown \
                --recursive \
                $MAIN_USER_NAME:$MAIN_USER_GROUP_NAME \
                "${DECRYPTED_PATHS_ARRAY[index]}"

            cp \
                --force \
                --recursive \
                "${ENCRYPTED_PATHS_ARRAY[index]}/"* \
                "${DECRYPTED_PATHS_ARRAY[index]}"

            if [ -s "${PASSWORD_FILE_PATHS_ARRAY[index]}" ]; then
                cp \
                    ${PASSWORD_FILE_PATHS_ARRAY[index]} \
                    /tmp/intermediatePasswordFile
            elif [[ "$DECRYPTION_PASSWORD" != '' ]]; then
                echo -n "$DECRYPTION_PASSWORD" >/tmp/intermediatePasswordFile
            elif [[ "$1" != '' ]]; then
                echo -n "$1" >/tmp/intermediatePasswordFile
            fi

            if [ -s /tmp/intermediatePasswordFile ]; then
                if ! decrypt \
                    "${DECRYPTED_PATHS_ARRAY[index]}" \
                    /tmp/intermediatePasswordFile
                then
                    echo \
                        Decrypting \"${ENCRYPTED_PATHS_ARRAY[index]}\" to \
                        \"${DECRYPTED_PATHS_ARRAY[index]}\" failed.

                    exit 1
                fi
            elif ! decrypt "${DECRYPTED_PATHS_ARRAY[index]}"; then
                echo \
                    Decrypting \"${ENCRYPTED_PATHS_ARRAY[index]}\" to \
                    \"${DECRYPTED_PATHS_ARRAY[index]}\" failed.

                exit 1
            fi
        fi
    done
fi
# endregion
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
