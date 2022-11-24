#!/usr/bin/bash

# crypt /from /to PASSWORD --decrypt

GPG_ARGS=(--batch --passphrase "$3")

FILES=$(find "$1" -type f)

# NOTE: Set internal field seperator to the newline character to handle paths
# with whitespaces.
IFS=$'\n'
set -f

for file_path in $FILES; do
    echo "Process \"$file_path\"."

    outfile="${file_path/$1/$2}"
    directory_path="$(dirname "$outfile")"
    if [ ! -d "$directory_path" ]; then
        echo "Create directory \"$directory_path\"."

        mkdir --parents "$directory_path"
    fi

    if [ "$4" == '--decrypt' ]; then
        gpg --decrypt --output "${outfile/.gpg/}" "${GPG_ARGS[@]}" "$file_path"
    else
        gpg --symmetric --output "${outfile}.gpg" "${GPG_ARGS[@]}" "$file_path"
    fi
done

unset IFS
set +f
