#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# region header
# Copyright Torben Sickert (info["~at~"]torben.website) 16.12.2012

# License
# -------

# This library written by Torben Sickert stand under a creative commons naming
# 3.0 unported license. See https://creativecommons.org/licenses/by/3.0/deed.de
# endregion
source get-bashlink

# crypt -d -p PASSWORD /from /to
# crypt --decrypt --password PASSWORD /from /to

decrypt=false
password=''
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

GPG_ARGUMENTS=(--batch)
if [[ "$password" != '' ]]; then
    GPG_ARGUMENTS+=(--passphrase "$password")
fi

FILES=$(find "$source_path" -type f)

# NOTE: Set internal field separator to the newline character to handle paths
# with whitespaces.
IFS=$'\n'
set -f

for file_path in $FILES; do
    bl.logging.info "Process \"$file_path\"."

    outfile="${file_path/$source_path/$target_path}"
    directory_path="$(dirname "$outfile")"
    if [ ! -d "$directory_path" ]; then
        bl.logging.info "Create directory \"$directory_path\"."

        mkdir --parents "$directory_path"
    fi

    if "$decrypt"; then
        gpg \
            --decrypt \
            --output "${outfile/.gpg/}" \
            --verbose \
            "${GPG_ARGUMENTS[@]}" \
            "$file_path" \
                1>/dev/null
    else
        gpg \
            --symmetric \
            --output "${outfile}.gpg" \
            --verbose \
            "${GPG_ARGUMENTS[@]}" \
            "$file_path" \
                1>/dev/null
    fi
done

unset IFS
set +f
