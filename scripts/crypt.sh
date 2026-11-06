#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# region header
# Copyright Torben Sickert (info["~at~"]tsickert.com) 16.12.2012

# License
# -------

# This library written by Torben Sickert stands under a creative commons naming
# 3.0 unported license. See https://creativecommons.org/licenses/by/3.0/deed.de
# endregion
# shellcheck source=SCRIPTDIR/get-bashlink.sh
source get-bashlink

# crypt -d -p PASSWORD /from /to
# crypt --decrypt --password PASSWORD /from /to
# crypt --decrypt --password-file /path/to/password/file /from /to
# NOTE: Prefer "--password-file" since a given password is visible in the
# process list.

decrypt=false
password=''
password_file_path=''
source_path=''
target_path=''
while true; do
    case "$1" in
        -d|--decrypt)
            shift
            decrypt=true
            ;;

        -p|--password)
            shift
            password="$1"
            shift
            ;;

        -f|--password-file)
            shift
            password_file_path="$1"
            shift
            ;;

        '')
            shift ||  true
            break
            ;;
        *)
            if [[ "$target_path" != '' ]]; then
                bl.logging.error "Given argument: \"$1\" is not available."
                exit 1
            elif [ "$source_path" = '' ]; then
                source_path="$1"
            elif [ "$target_path" = '' ]; then
                target_path="$1"
            fi

            shift
    esac
done

GPG_ARGUMENTS=(--batch --pinentry-mode loopback)
if [[ "$password_file_path" != '' ]]; then
    GPG_ARGUMENTS+=(--passphrase-file "$password_file_path")
elif [[ "$password" != '' ]]; then
    GPG_ARGUMENTS+=(--passphrase "$password")
fi

failed=false
while IFS= read -r -d '' file_path; do
    bl.logging.info "Process \"$file_path\"."

    # NOTE: Replace the leading source path literally (not as pattern).
    outfile="${target_path}${file_path#"$source_path"}"
    directory_path="$(dirname "$outfile")"
    if [ ! -d "$directory_path" ]; then
        bl.logging.info "Create directory \"$directory_path\"."

        mkdir --parents "$directory_path"
    fi

    if "$decrypt"; then
        gpg_arguments=(--decrypt --output "${outfile%.gpg}")
    else
        gpg_arguments=(--symmetric --output "${outfile}.gpg")
    fi

    # NOTE: Prevent gpg from consuming the file list given via stdin.
    if ! gpg \
        "${gpg_arguments[@]}" \
        --quiet \
        "${GPG_ARGUMENTS[@]}" \
        "$file_path" \
            1>/dev/null \
            </dev/null
    then
        bl.logging.error "Processing \"$file_path\" failed."

        failed=true
    fi
done < <(find "$source_path" -type f -print0)

if "$failed"; then
    exit 1
fi
