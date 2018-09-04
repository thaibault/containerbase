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
# NOTE: Current version of the application will live in the image. For
# development scenarios we can simply mount our working copy over the
# application root.
for path in \
    "$APPLICATION_USER_ID_INDICATOR_FILE_PATH" "$INITIALIZING_FILE_PATH"
do
    touch "$path" && chown "${MAIN_USER_NAME}:${MAIN_USER_GROUP_NAME}" "$path"
done
if \
    [ "$STANDALONE" = true ] && \
    [[ "$PRIVATE_SSH_KEY" != '' ]] && \
    [[ "$PUBLIC_SSH_KEY" != '' ]] && \
    [[ "$REPOSITORY_URL" != '' ]]
then
    cd && \
    mkdir --parents .ssh && \
    echo -e "$PRIVATE_SSH_KEY" >.ssh/id_rsa && \
    chmod 600 .ssh/id_rsa && \
    echo -e "$PUBLIC_SSH_KEY" >.ssh/id_rsa.pub && \
    chmod 600 .ssh/id_rsa.pub && \
    echo -e "$KNOWN_HOSTS" >.ssh/known_hosts && \
    chmod 600 .ssh/known_hosts && \
    mkdir --parents "$(dirname "$APPLICATION_PATH")"
    rm --force --recursive "$APPLICATION_PATH" &>/dev/null
    git \
        clone \
        --depth 1 \
        --no-single-branch \
        "$REPOSITORY_URL" \
        "$APPLICATION_PATH" && \
    git checkout "$([ "$BRANCH" = '' ] && echo master || echo "$BRANCH")" && \
    touch "$APPLICATION_USER_ID_INDICATOR_FILE_PATH" && \
    cd "$APPLICATION_PATH" && \
    git submodule init && \
    git submodule foreach \
        'branch="$(git config --file "$toplevel/.gitmodules" "submodule.$name.branch")";git clone --depth 1 --branch "$branch"' && \
    git submodule update --remote && \
    rm --recursive --force .git && \
    chown \
        "${MAIN_USER_NAME}:${MAIN_USER_GROUP_NAME}" \
        "$APPLICATION_USER_ID_INDICATOR_FILE_PATH" && \
    chown \
        --recursive \
        "${MAIN_USER_NAME}:${MAIN_USER_GROUP_NAME}" \
        "$APPLICATION_PATH" && \
    pwd
fi
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
