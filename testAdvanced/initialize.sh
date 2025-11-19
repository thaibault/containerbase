#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# shellcheck disable=SC1091

set -e

source get-bashlink

source prepare-initializer "$@"

bl.logging.info Application started.

source configure-runtime-user

source decrypt "$@"

bl.logging.info \
    "Decrypted content of encrypted folder \"$ENCRYPTED_PATHS\" located at" \
    "\"$DECRYPTED_PATHS\" is:"

tree "$DECRYPTED_PATHS"

bl.logging.info \
    "Example file content of \"${DECRYPTED_PATHS}secret-configuration.txt\"" \
    "is \"$(cat "${DECRYPTED_PATHS}secret-configuration.txt")\"."

bl.logging.info First level meta file data are:

ls --all --human-readable -l "$DECRYPTED_PATHS"
