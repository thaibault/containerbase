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
if [[ "$MAIN_USER_NAME" != root ]]; then
    if grep --quiet "$MAIN_USER_GROUP_NAME" /etc/group; then
        groupmod \
            --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
            "$MAIN_USER_GROUP_NAME"
    else
        groupadd \
            --gid "$DEFAULT_MAIN_USER_GROUP_ID"
            "$MAIN_USER_GROUP_NAME"
    fi
    existing_user_id="$(id --user "$MAIN_USER_NAME" 2>/dev/null)"
    existing_user_name="$(
        getent passwd "$DEFAULT_MAIN_USER_ID" | \
            cut --delimiter : --fields 1)"
    if [ "$existing_user_id" = '' ] && [ "$existing_user_name" = '' ]; then
        useradd \
            --create-home \
            --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
            --no-user-group \
            --uid "$DEFAULT_MAIN_USER_ID" \
            "$MAIN_USER_NAME"
    elif (( existing_user_id != DEFAULT_MAIN_USER_ID )); then
        if [ "$existing_user_name" = '' ]; then
            usermod \
                --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                --uid "$DEFAULT_MAIN_USER_ID" \
                "$MAIN_USER_NAME"
        elif [ "$existing_user_name" = "$MAIN_USER_NAME" ]; then
            usermod \
                --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                --uid "$DEFAULT_MAIN_USER_ID" \
                "$existing_user_name"
        elif [ "$existing_user_id" = '' ]; then
            usermod \
                --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                --login "$MAIN_USER_NAME" \
                "$existing_user_name"
        else
            userdel --force "$existing_user_name"
            usermod \
                --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                --uid "$DEFAULT_MAIN_USER_ID" \
                "$MAIN_USER_NAME"
        fi
    fi
    chown \
        --recursive \
        "${MAIN_USER_NAME}:${MAIN_USER_GROUP_NAME}" \
        "$(pwd)" && \
    echo /usr/bin/bash>>/etc/shells && \
    chsh --shell /usr/bin/bash "$MAIN_USER_NAME" && \
    usermod --home "$(pwd)" "$MAIN_USER_NAME" && \
    pwd
fi
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
