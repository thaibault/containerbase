#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# region header
# Copyright Torben Sickert (info["~at~"]torben.website) 16.12.2012

# License
# -------

# This library written by Torben Sickert stand under a creative commons naming
# 3.0 unported license. see http://creativecommons.org/licenses/by/3.0/deed.de
# endregion
# shellcheck disable=SC2016,SC2034,SC2155
# Set proper default user and group id to avoid expensive user id
# mapping on application startup.
[[ "$MAIN_USER_NAME" != root ]] && ( \
    id --user "$MAIN_USER_NAME" &>/dev/null || \
    useradd \
        --create-home \
        --no-user-group \
        "$MAIN_USER_NAME" \
) && \
groupmod \
    --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
    "$MAIN_USER_GROUP_NAME" && \
usermod \
    --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
    --uid "$DEFAULT_MAIN_USER_ID" \
    "$MAIN_USER_NAME" && \
chown \
    --recursive \
    "${MAIN_USER_NAME}:${MAIN_USER_GROUP_NAME}" \
    "$(pwd)" && \
echo /usr/bin/bash>>/etc/shells && \
chsh --shell /usr/bin/bash "$MAIN_USER_NAME" && \
usermod --home "$(pwd)" "$MAIN_USER_NAME" || \
true
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
