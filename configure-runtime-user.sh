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
EXISTING_USER_GROUP_ID=$(id --group "$MAIN_USER_NAME")
EXISTING_USER_ID=$(id --user "$MAIN_USER_NAME")
USER_GROUP_ID_CHANGED=false
if [ "$HOST_USER_GROUP_ID" = '' ]; then
    HOST_USER_GROUP_ID="$(
        stat --format '%g' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH")"
fi
if (( EXISTING_USER_GROUP_ID == 0 )); then
    echo Host user group id is \"0\" \(root\), ignoring user mapping.
elif (( EXISTING_USER_GROUP_ID != HOST_USER_GROUP_ID )); then
    echo \
        Map group id $EXISTING_USER_GROUP_ID from application user \
        $MAIN_USER_NAME to host group id $HOST_USER_GROUP_ID from \
        $(stat --format '%G' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH").
    usermod --gid "$HOST_USER_GROUP_ID" "$MAIN_USER_NAME"
    USER_GROUP_ID_CHANGED=true
fi
if [ "$HOST_USER_ID" = '' ]; then
    HOST_USER_ID="$(
        stat --format '%u' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH")"
fi
USER_ID_CHANGED=false
if (( EXISTING_USER_ID == 0 )); then
    echo Host user group id is \"0\" \(root\), ignoring user mapping.
elif (( EXISTING_USER_ID != HOST_USER_ID )); then
    echo \
        Map user id $EXISTING_USER_ID from application user $MAIN_USER_NAME \
        to host user id $HOST_USER_ID from \
        $(stat --format '%U' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH").
    usermod --uid "$HOST_USER_ID" "$MAIN_USER_NAME"
    USER_ID_CHANGED=true
fi
for path in "$@"; do
    if $USER_GROUP_ID_CHANGED; then
        find \
            "$path" \
            -exec chgrp \
            -group $EXISTING_USER_GROUP_ID \
            --no-dereference \
            -xdev \
            $MAIN_USER_GROUP_NAME {} \;
    fi
    if $USER_ID_CHANGED; then
        find \
            "$path" \
            -exec chown \
            --no-dereference \
            -user $EXISTING_USER_ID \
            -xdev \
            $MAIN_USER_NAME {} \;
    fi
done
if $USER_GROUP_ID_CHANGED || $USER_ID_CHANGED; then
    chmod +x /dev/
    chown \
        --dereference \
        -L \
        "$MAIN_USER_NAME:$MAIN_USER_GROUP_NAME" \
        /proc/self/fd/0 \
        /proc/self/fd/1 \
        /proc/self/fd/2
fi
set +x
command="$(eval "echo $COMMAND")"
if [[ "$command" != '' ]]; then
    echo Run command \"$command\"
    exec su "$MAIN_USER_NAME" --group "$MAIN_USER_GROUP_NAME" -c "$command"
fi
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
