#!/usr/bin/bash
# -*- coding: utf-8 -*-
set -e

source prepare-initializer "$@"

source configure-runtime-user

echo \
    Application started: Decrypted content of encrypted folder \
    \"$ENCRYPTED_PATHS\" located at \"$DECRYPTED_PATHS\" is \
    \"$(tree $DECRYPTED_PATHS)\". Example file content of \
    \"${DECRYPTED_PATHS}secret-configuration.txt\" is \
    "$(cat "${DECRYPTED_PATHS}secret-configuration.txt")".
