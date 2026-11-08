#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# region header
# [Project page](https://tsickert.com/containerbase)

# Copyright Torben Sickert (info["~at~"]tsickert.com) 16.12.2012

# License
# -------

# This library written by Torben Sickert stands under a creative commons naming
# 3.0 unported license.
# See https://creativecommons.org/licenses/by/3.0/deed.de
# endregion
# shellcheck disable=SC2155
# shellcheck source=SCRIPTDIR/get-bashlink.sh
source get-bashlink

# region convert environment variables given as string into local arrays
for name in \
    DECRYPTED_PATHS \
    ENCRYPTED_PATHS \
    ENVIRONMENT_FILE_PATHS \
    PASSWORD_FILE_PATHS \
    PASSWORD_SECRET_NAMES
do
    if [[ "$(declare -p "$name" 2>/dev/null)" =~ 'declare -a' ]]; then
        eval "declare -a ${name}_ARRAY=(\"\${${name}[@]}\")"
    else
        eval "declare -a ${name}_ARRAY=(\$${name})"
    fi
done
# endregion
# region load dynamic environment variables
for file_path in "${ENVIRONMENT_FILE_PATHS_ARRAY[@]}"; do
    if [ -f "$file_path" ]; then
        # shellcheck disable=SC1090
        source "$file_path"
    fi
done
# endregion
if [[ "$DECRYPT" != false ]]; then
    # region determine encrypter
    declare -r current_path="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/"
    for encrypter in \
        ./crypt.sh \
        ./scripts/crypt.sh \
        /usr/bin/crypt \
        "${current_path}crypt.sh" \
        "${current_path}scripts/crypt.sh"
    do
        if [ -f "$encrypter" ]; then
            break
        fi
    done
    # endregion
    # region decrypt security related artifacts needed at runtime
    for index in "${!ENCRYPTED_PATHS_ARRAY[@]}"; do
        if [ -d "${ENCRYPTED_PATHS_ARRAY[index]}" ]; then
            rm \
                --force \
                --recursive \
                "${DECRYPTED_PATHS_ARRAY[index]}" \
                &>/dev/null

            # region determine password file
            password_file_path=''
            temporary_password_file_path=''
            secret_name="${PASSWORD_SECRET_NAMES_ARRAY[index]}"
            if \
                [[ "$secret_name" != '' ]] && \
                [ -s "/run/secrets/$secret_name" ]
            then
                password_file_path="/run/secrets/$secret_name"
            elif [ -s "${PASSWORD_FILE_PATHS_ARRAY[index]}" ]; then
                password_file_path="${PASSWORD_FILE_PATHS_ARRAY[index]}"
            elif [[ "$DECRYPTION_PASSWORD" != '' ]] || [[ "$1" != '' ]]; then
                # NOTE: Do not leave the plain password in the file system.
                temporary_password_file_path="$(mktemp)"
                password_file_path="$temporary_password_file_path"
                printf '%s' "${DECRYPTION_PASSWORD:-$1}" \
                    >"$password_file_path"
            fi

            password_arguments=()
            if [[ "$password_file_path" != '' ]]; then
                password_arguments=(--password-file "$password_file_path")
            fi
            # endregion
            succeeded=true
            "$encrypter" \
                --decrypt \
                "${password_arguments[@]}" \
                "${ENCRYPTED_PATHS_ARRAY[index]}" \
                "${DECRYPTED_PATHS_ARRAY[index]}" || \
                    succeeded=false

            if [[ "$temporary_password_file_path" != '' ]]; then
                rm --force "$temporary_password_file_path"
            fi

            if ! "$succeeded"; then
                bl.logging.error \
                    "Decrypting \"${ENCRYPTED_PATHS_ARRAY[index]}\" to" \
                    "\"${DECRYPTED_PATHS_ARRAY[index]}\" failed."

                exit 1
            fi

            bl.logging.info \
                "Decrypting \"${ENCRYPTED_PATHS_ARRAY[index]}\" to" \
                "\"${DECRYPTED_PATHS_ARRAY[index]}\" successfully finished."
        fi
    done
    # endregion
fi
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
