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
declare -ir EXISTING_USER_GROUP_ID=$(id --group "$MAIN_USER_NAME")
declare -ir EXISTING_USER_ID=$(id --user "$MAIN_USER_NAME")
USER_GROUP_ID_CHANGED=false
if [ "$HOST_USER_GROUP_ID" = '' ]; then
    HOST_USER_GROUP_ID="$(
        stat --format '%g' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH")"
fi
if (( HOST_USER_GROUP_ID == 0 )); then
    echo Host user group id is \"0\" \(root\), ignoring user mapping.
elif (( EXISTING_USER_GROUP_ID != HOST_USER_GROUP_ID )); then
    echo \
        Map group id $EXISTING_USER_GROUP_ID from application user \
        \"$MAIN_USER_NAME\" to host group id $HOST_USER_GROUP_ID from \
        \"$(stat --format '%G' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH")\".
    declare -r existing_user_group_name="$(
        getent group "$HOST_USER_GROUP_ID" | \
            cut --delimiter : --fields 1)"
    if [ "$EXISTING_USER_GROUP_ID" = '' ]; then
        usermod --gid "$HOST_USER_GROUP_ID" "$MAIN_USER_GROUP_NAME"
        USER_GROUP_ID_CHANGED=true
    else
        echo \
            Host user group id $HOST_USER_GROUP_ID could not be mapped into \
            container since this group id id is already used by application \
            user group \"$existing_user_group_name\". &>2
        exit 1
    fi
fi
if [ "$HOST_USER_ID" = '' ]; then
    HOST_USER_ID="$(
        stat --format '%u' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH")"
fi
USER_ID_CHANGED=false
if (( HOST_USER_ID == 0 )); then
    echo Host user id is \"0\" \(root\), ignoring user mapping.
elif (( EXISTING_USER_ID != HOST_USER_ID )); then
    echo \
        Map user id $EXISTING_USER_ID from application user \
        \"$MAIN_USER_NAME\" to host user id $HOST_USER_ID from \
        \"$(stat --format '%U' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH")\".
    declare -r existing_user_name="$(
        getent passwd "$HOST_USER_ID" | \
            cut --delimiter : --fields 1)"
    if [ "$EXISTING_USER_ID" = '' ]; then
        usermod --uid "$HOST_USER_ID" "$MAIN_USER_NAME"
        USER_ID_CHANGED=true
    else
        echo \
            Host user id $HOST_USER_ID could not be mapped into container \
            since this user id is already used by application user \
            \"$existing_user_name\". &>2
        exit 1
    fi
fi
for path in "$@"; do
    if $USER_GROUP_ID_CHANGED; then
        find \
            "$path" \
            -group $EXISTING_USER_GROUP_ID \
            --no-dereference \
            -xdev \
            -exec chgrp $MAIN_USER_GROUP_NAME {} \;
    fi
    if $USER_ID_CHANGED; then
        find \
            "$path" \
            --no-dereference \
            -user $EXISTING_USER_ID \
            -xdev \
            -exec chown $MAIN_USER_NAME {} \;
    fi
done
if (( HOST_USER_GROUP_ID != 0 )) && (( HOST_USER_ID != 0 )); then
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
