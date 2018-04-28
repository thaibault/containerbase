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
    if (( DEFAULT_MAIN_USER_GROUP_ID == 0 )); then
        echo \
            If you define \"0\" as default main user group id \"MAIN_USER_GROUP_NAME\" \
            has to be configured as \"root\". \
            &>/dev/stderr
        exit 1
    fi
    if (( DEFAULT_MAIN_USER_ID == 0 )); then
        echo \
            If you define \"0\" as default main user id \"MAIN_USER_NAME\" \
            has to be configured as \"root\". \
            &>/dev/stderr
        exit 1
    fi
    if grep --quiet "$MAIN_USER_GROUP_NAME" /etc/group; then
        # Change existing group id to specified one.
        groupmod \
            --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
            "$MAIN_USER_GROUP_NAME"
    else
        # Create non existing group with specified id.
        groupadd \
            --gid "$DEFAULT_MAIN_USER_GROUP_ID"
            "$MAIN_USER_GROUP_NAME"
    fi
    # NOTE: We have to create or modify existing user depending on user names
    # or ids which have been assigned already.
    existing_user_id="$(id --user "$MAIN_USER_NAME" 2>/dev/null)"
    existing_user_name="$(
        getent passwd "$DEFAULT_MAIN_USER_ID" | \
            cut --delimiter : --fields 1)"
    if [ "$existing_user_id" = '' ] && [ "$existing_user_name" = '' ]; then
        # Create specified user with not yet existing name and id.
        useradd \
            --create-home \
            --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
            --no-user-group \
            --uid "$DEFAULT_MAIN_USER_ID" \
            "$MAIN_USER_NAME"
    elif (( existing_user_id != DEFAULT_MAIN_USER_ID )); then
        if [ "$existing_user_name" = '' ]; then
            # Change existing user (name already exists) to specified user and
            # group id.
            usermod \
                --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                --uid "$DEFAULT_MAIN_USER_ID" \
                "$MAIN_USER_NAME"
        elif [ "$existing_user_name" = "$MAIN_USER_NAME" ]; then
            # Change existing user (id already exists and name matches
            # specified one) group id to specified one.
            usermod \
                --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                "$existing_user_name"
        elif [ "$existing_user_id" = '' ]; then
            # Change existing user (id already exists) to specified user name
            # and group id.
            usermod \
                --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                --login "$MAIN_USER_NAME" \
                "$existing_user_name"
        else
            # Remove existing user with clashing user id and change user and
            # group id of already existing user (name already exists).
            userdel --force "$existing_user_name"
            usermod \
                --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                --uid "$DEFAULT_MAIN_USER_ID" \
                "$MAIN_USER_NAME"
        fi
    # else -> A user already exist with specified user and group id.
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
