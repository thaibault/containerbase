#!/usr/bin/bash
# -*- coding: utf-8 -*-
set -e

echo Application started.
source prepare-initializer "$@"

source configure-runtime-user

echo \
    Decrypted content of encrypted folder \"$ENCRYPTED_PATHS\" located at \
    \"$DECRYPTED_PATHS\" is \"$(tree $DECRYPTED_PATHS)\". Example file \
    content of \"${DECRYPTED_PATHS}secret-configuration.txt\" is \
    "$(cat "${DECRYPTED_PATHS}secret-configuration.txt")".
