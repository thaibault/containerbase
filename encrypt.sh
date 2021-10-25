#!/usr/bin/bash
# -*- coding: utf-8 -*-
# [Project page](https://torben.website/containerbase)

# Copyright Torben Sickert (info["~at~"]torben.website) 16.12.2012

# License
# -------

# This library written by Torben Sickert stand under a creative commons naming
# 3.0 unported license.
# See https://creativecommons.org/licenses/by/3.0/deed.de

# Basic ArchLinux with user-mapping, AUR integration and support for decryption
# of security related files.

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
ls test -lha
ls -lha /usr/bin/perlbin/site_perl/
# region encrypt security related artefacts needed at runtime
if [[ "$DECRYPT" != false ]]; then
    for index in "${!ENCRYPTED_PATHS_ARRAY[@]}"; do
        if [ -d "${DECRYPTED_PATHS_ARRAY[index]}" ]; then
            rm \
                --force \
                --recursive \
                "${ENCRYPTED_PATHS_ARRAY[index]}" \
                    &>/dev/null
            mkdir --parents "${ENCRYPTED_PATHS_ARRAY[index]}"
            chown \
                --recursive \
                $MAIN_USER_NAME:$MAIN_USER_GROUP_NAME \
                "${ENCRYPTED_PATHS_ARRAY[index]}"

            cp \
                --force \
                --recursive \
                "${DECRYPTED_PATHS_ARRAY[index]}" \
                "${ENCRYPTED_PATHS_ARRAY[index]}"

            if [ -s "${PASSWORD_FILE_PATHS_ARRAY[index]}" ]; then
                cp \
                    ${PASSWORD_FILE_PATHS_ARRAY[index]} \
                    /tmp/intermediatePasswordFile
            elif [[ "$1" != '' ]]; then
                echo -n "$1" >/tmp/intermediatePasswordFile
            fi

            if [ -s /tmp/intermediatePasswordFile ]; then
                if ! /usr/bin/perlbin/site_perl/gpgdir \
                    --encrypt "${ENCRYPTED_PATHS_ARRAY[index]}" \
                    --overwrite-encrypted \
                    --pw-file /tmp/intermediatePasswordFile \
                    --Symmetric \
                    --verbose
                then
                    echo \
                        Encrypting \"${DECRYPTED_PATHS_ARRAY[index]}\" to \
                        \"${ENCRYPTED_PATHS_ARRAY[index]}\" failed.

                    exit 1
                fi
            elif ! /usr/bin/perlbin/site_perl/gpgdir \
                --encrypt "${ENCRYPTED_PATHS_ARRAY[index]}" \
                --overwrite-encrypted \
                --Symmetric \
                --verbose
            then
                echo \
                    Encrypting \"${DECRYPTED_PATHS_ARRAY[index]}\" to \
                    \"${ENCRYPTED_PATHS_ARRAY[index]}\" failed.

                exit 1
            fi

            echo \
                Encrypting \"${DECRYPTED_PATHS_ARRAY[index]}\" to \
                \"${ENCRYPTED_PATHS_ARRAY[index]}\" successfully finished.
        fi
    done
fi
# endregion
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
