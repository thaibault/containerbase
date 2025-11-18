#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# region header
# Copyright Torben Sickert (info["~at~"]torben.website) 16.12.2012

# License
# -------

# This library written by Torben Sickert stand under a creative commons naming
# 3.0 unported license. See https://creativecommons.org/licenses/by/3.0/deed.de
# endregion
# shellcheck disable=SC2155
source ./bashlink/module.sh
bl.module.import bashlink.logging

# Disable root account expiration.
chage --expiredate -1 root && \
# Set proper default user and group id to avoid expensive user id mapping on
# application startup.
if [[ "$MAIN_USER_NAME" != root ]]; then
    if (( DEFAULT_MAIN_USER_GROUP_ID == 0 )); then
        bl.logging.error \
            If you define 0 as default main user group id \
            \"MAIN_USER_GROUP_NAME\" has to be configured as \"root\". \
            &>/dev/stderr

        exit 1
    fi
    if (( DEFAULT_MAIN_USER_ID == 0 )); then
        bl.logging.error \
            If you define 0 as default main user id \"MAIN_USER_NAME\" has \
            to be configured as \"root\". \
            &>/dev/stderr

        exit 1
    fi

    # NOTE: We have to create or modify existing user group depending on user
    # group names or ids which have been assigned already.
    declare -r existing_user_group_id="$(
        getent group "$MAIN_USER_GROUP_NAME" | \
            cut --delimiter : --fields 3
    )"
    declare -r existing_user_group_name="$(
        getent group "$DEFAULT_MAIN_USER_GROUP_ID" | \
            cut --delimiter : --fields 1
    )"

    if [[
        (
            "$existing_user_group_id" = '' ||
            "$existing_user_group_id" = UNKNOWN
        ) && (
            "$existing_user_group_name" = '' ||
            "$existing_user_group_name" = UNKNOWN
        )
    ]]; then
        # Create specified user group with not yet existing name and id.
        groupadd --gid "$DEFAULT_MAIN_USER_GROUP_ID" "$MAIN_USER_GROUP_NAME"
    elif (( existing_user_group_id != DEFAULT_MAIN_USER_GROUP_ID )); then
        if \
            [ "$existing_user_group_name" = '' ] ||
            [ "$existing_user_group_name" = UNKNOWN ]
        then
            # Change existing user group (name already exists) to specified
            # user group id.
            groupmod \
                --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                "$MAIN_USER_GROUP_NAME"
        elif [ "$existing_user_group_name" = "$MAIN_USER_GROUP_NAME" ]; then
            # Change existing user group (id already exists and name matches
            # specified one) id to specified one.
            groupmod \
                --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                "$existing_user_group_name"
        elif \
            [ "$existing_user_group_id" = '' ] || \
            [ "$existing_user_group_id" = UNKNOWN ]
        then
            # Change existing user group (id already exists) to specified user
            # group name and id.
            groupmod \
                --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                --new-name "$MAIN_USER_GROUP_NAME" \
                "$existing_user_group_name"
        else
            # Remove existing user group with clashing user group id and change
            # user group id of already existing user group (name already
            # exists).
            groupdel --force "$existing_user_group_name"
            groupmod \
                --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
                "$MAIN_USER_GROUP_NAME"
        fi
    # else -> A user group already exist with specified user group id.
    fi

    # NOTE: We have to create or modify existing user depending on user names
    # or ids which have been assigned already.
    declare -r existing_user_id="$(id --user "$MAIN_USER_NAME" 2>/dev/null)"
    declare -r existing_user_name="$(
        getent passwd "$DEFAULT_MAIN_USER_ID" | \
            cut --delimiter : --fields 1)"

    if [[
        (
            "$existing_user_id" = '' ||
            "$existing_user_id" = UNKNOWN
        ) && (
            "$existing_user_name" = '' ||
            "$existing_user_name" = UNKNOWN
        )
    ]]; then
        # Create specified user with not yet existing name and id.
        useradd \
            --create-home \
            --gid "$DEFAULT_MAIN_USER_GROUP_ID" \
            --no-user-group \
            --uid "$DEFAULT_MAIN_USER_ID" \
            "$MAIN_USER_NAME"
    elif (( existing_user_id != DEFAULT_MAIN_USER_ID )); then
        if \
            [ "$existing_user_name" = '' ] || \
            [ "$existing_user_name" = UNKNOWN ]
        then
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
        elif \
            [ "$existing_user_id" = '' ] || \
            [ "$existing_user_id" = UNKNOWN ]
        then
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

    # Disable user account expiration.
    chage --expiredate -1 "$MAIN_USER_NAME" && \
    chown \
        --recursive \
        "${MAIN_USER_NAME}:${MAIN_USER_GROUP_NAME}" \
        "$(pwd)" && \
    echo /usr/bin/bash >>/etc/shells && \
    chsh --shell /usr/bin/bash "$MAIN_USER_NAME" && \
    mkdir --parents "/home/${MAIN_USER_NAME}" && \
    chown \
        --recursive \
        "${MAIN_USER_NAME}:${MAIN_USER_GROUP_NAME}" \
        "/home/${MAIN_USER_NAME}" && \
    usermod --home "/home/${MAIN_USER_NAME}" "$MAIN_USER_NAME" && \

    pwd
fi
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
