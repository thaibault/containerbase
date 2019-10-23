#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# region header
# Copyright Torben Sickert (info["~at~"]torben.website) 16.12.2012

# License
# -------

# This library written by Torben Sickert stand under a creative commons naming
# 3.0 unported license. See https://creativecommons.org/licenses/by/3.0/deed.de
# endregion
# shellcheck disable=SC2016,SC2034,SC2155
export EXISTING_USER_GROUP_ID=$(id --group "$MAIN_USER_NAME")
export EXISTING_USER_ID=$(id --user "$MAIN_USER_NAME")
export USER_GROUP_ID_CHANGED=false
if [ "$HOST_USER_GROUP_ID" = '' ] || [ "$HOST_USER_GROUP_ID" = UNKNOWN ]; then
    export HOST_USER_GROUP_ID="$(
        stat --format '%g' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH")"
fi
if (( HOST_USER_GROUP_ID == 0 )); then
    echo Host user group id is \"0\" \(root\), ignoring user mapping.
elif (( EXISTING_USER_GROUP_ID != HOST_USER_GROUP_ID )); then
    echo \
        Map container\'s existing user group id $EXISTING_USER_GROUP_ID \
        \(\"$MAIN_USER_GROUP_NAME\"\) from container\'s application user \
        \"$MAIN_USER_NAME\" to host\'s group id $HOST_USER_GROUP_ID \
        \(\"$(stat --format '%G' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH")\"\).
    declare -r existing_user_group_name="$(
        getent group "$HOST_USER_GROUP_ID" | \
            cut --delimiter : --fields 1)"
    export USER_GROUP_ID_CHANGED=true
    if [ "$existing_user_group_name" = '' ]; then
        if \
            [ "$EXISTING_USER_GROUP_ID" = '' ] || \
            [ "$EXISTING_USER_GROUP_ID" = UNKNOWN ]
        then
            echo \
                Host user group id does not exist in container and container \
                does not have any application user group \
                \"$MAIN_USER_GROUP_NAME\". Creating corresponding user group \
                and assign to the application user \"$MAIN_USER_NAME\".
            groupadd --gid "$HOST_USER_GROUP_ID" "$MAIN_USER_GROUP_NAME"
            usermod --gid "$HOST_USER_GROUP_ID" "$MAIN_USER_NAME"
        else
            echo \
                Host user group id does not exist in container and container \
                has already an application user group \
                \"$MAIN_USER_GROUP_NAME\". Changing corresponding user group \
                id and assign to the application user \"$MAIN_USER_NAME\".
            groupmod --gid "$HOST_USER_GROUP_ID" "$MAIN_USER_GROUP_NAME"
        fi
    elif \
        [ "$EXISTING_USER_GROUP_ID" = '' ] || \
        [ "$EXISTING_USER_GROUP_ID" = UNKNOWN ]
    then
        echo \
            Current application user \"$MAIN_USER_NAME\" has no corresponding \
            group and hosts one exists in container \
            \"$existing_user_group_name\": assign it to them.
        usermod --gid "$HOST_USER_GROUP_ID" "$MAIN_USER_NAME"
        groupmod --new-name "$MAIN_USER_NAME" "$existing_user_group_name"
    else
        echo \
            Host user group id $HOST_USER_GROUP_ID could not be mapped into \
            container since this group id is already used by application user \
            group \"$existing_user_group_name\". &>/dev/stderr
        sync
        exit 1
    fi
fi
if [ "$HOST_USER_ID" = '' ] || [ "$HOST_USER_ID" = UNKNOWN ]; then
    export HOST_USER_ID="$(
        stat --format '%u' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH")"
fi
export USER_ID_CHANGED=false
if (( HOST_USER_ID == 0 )); then
    echo Host user id is \"0\" \(root\), ignoring user mapping.
elif (( EXISTING_USER_ID != HOST_USER_ID )); then
    echo \
        Map container\'s existing application user id $EXISTING_USER_ID \
        \(\"$MAIN_USER_NAME\"\) to host\'s user id $HOST_USER_ID \
        \(\"$(stat --format '%U' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH")\"\).
    declare -r existing_user_name="$(
        getent passwd "$HOST_USER_ID" | \
            cut --delimiter : --fields 1)"
    export USER_ID_CHANGED=true
    if [ "$existing_user_name" = '' ]; then
        if \
            [ "$EXISTING_USER_ID" = '' ] || [ "$EXISTING_USER_ID" = UNKNOWN ]
        then
            echo \
                Host user id does not exist in container and container does \
                not have any application user \"$MAIN_USER_NAME\". Creating \
                corresponding user and assign id to them.
            useradd \
                --create-home \
                --gid "$HOST_USER_GROUP_ID" \
                --no-user-group \
                --uid "$HOST_USER_ID" \
                "$MAIN_USER_NAME"
        else
            echo \
                Host user group id does not exist in container and container \
                has already an application user \"$MAIN_USER_NAME\". \
                Changing corresponding user id.
            usermod --uid "$HOST_USER_ID" "$MAIN_USER_NAME"
        fi
    elif [ "$EXISTING_USER_ID" = '' ] || [ "$EXISTING_USER_ID" = UNKNOWN ]; then
        echo \
            Current application user \"$MAIN_USER_NAME\" does not exist but \
            hosts one \"$existing_user_name\". Change corresponding user id \
            to hosts one.
        usermod \
            --login "$MAIN_USER_NAME" \
            --uid "$HOST_USER_ID" \
            "$existing_user_name"
        usermod --home "/home/$MAIN_USER_NAME" --move-home "$MAIN_USER_NAME"
    else
        echo \
            Host user id $HOST_USER_ID could not be mapped into container \
            since this user id is already used by application user \
            \"$existing_user_name\". &>/dev/stderr
        exit 1
    fi
fi
# Disable user account expiration.
for user_name in root "$MAIN_USER_NAME"; do
    chage --expiredate -1 "$user_name"
done
for path in "$@"; do
    all=false
    follow=false
    # NOTE: This case has to be handled before the other to avoid shadowing.
    if [[ "$path" == *:all:follow ]] || [[ $path == *:follow:all ]]; then
        all=true
        follow=true
        path=${path%:all:follow}
        path=${path%:follow:all}
    elif [[ "$path" == *:all ]]; then
        all=true
        path=${path%:all}
    elif [[ "$path" == *:follow ]]; then
        follow=true
        path=${path%:follow}
    fi
    if $all; then
        find \
            "$path" \
            -xdev \
            -exec \
                chgrp \
                    --no-dereference \
                    --preserve-root \
                    "$MAIN_USER_GROUP_NAME" \
                    {} \
                    \;
        if $follow; then
            find \
                "$path" \
                -xdev \
                -exec \
                    chgrp \
                        --dereference \
                        -H \
                        --preserve-root \
                        --recursive \
                        "$MAIN_USER_GROUP_NAME" \
                        {} \
                        \;
        fi
    elif \
        ! $all && \
        $USER_GROUP_ID_CHANGED && \
        [[ "$EXISTING_USER_GROUP_ID" != '' ]] && \
        [[ "$EXISTING_USER_GROUP_ID" != UNKNOWN ]]
    then
        find \
            "$path" \
            -group $EXISTING_USER_GROUP_ID \
            -xdev \
            -exec \
                chgrp \
                    --no-dereference \
                    --preserve-root \
                    "$MAIN_USER_GROUP_NAME" \
                    {} \
                    \;
        if $follow; then
            find \
                "$path" \
                -group $EXISTING_USER_GROUP_ID \
                -xdev \
                -exec \
                    chgrp \
                        --dereference \
                        -H \
                        --preserve-root \
                        --recursive \
                        "$MAIN_USER_GROUP_NAME" \
                        {} \
                        \;
        fi
    fi
    if $all; then
        find \
            "$path" \
            -xdev \
            -exec \
                chown \
                    --no-dereference \
                    --preserve-root \
                    "$MAIN_USER_NAME" \
                    {} \
                    \;
        if $follow; then
            find \
                "$path" \
                -xdev \
                -exec \
                    chown \
                        --dereference \
                        -H \
                        --preserve-root \
                        --recursive \
                        "$MAIN_USER_NAME" \
                        {} \
                        \;
        fi
    elif \
        $USER_ID_CHANGED && \
        [[ "$EXISTING_USER_ID" != '' ]] && \
        [[ "$EXISTING_USER_ID" != UNKNOWN ]]
    then
        find \
            "$path" \
            -user $EXISTING_USER_ID \
            -xdev \
            -exec \
                chown \
                    --no-dereference \
                    --preserve-root \
                    "$MAIN_USER_NAME" \
                    {} \
                    \;
        if $follow; then
            find \
                "$path" \
                -user $EXISTING_USER_ID \
                -xdev \
                -exec \
                    chown \
                        --dereference \
                        -H \
                        --preserve-root \
                        --recursive \
                        "$MAIN_USER_NAME" \
                        {} \
                        \;
        fi
    fi
done
if (( HOST_USER_GROUP_ID != 0 )) && (( HOST_USER_ID != 0 )); then
    chmod +x /dev/
    chown \
        --dereference \
        -H \
        --preserve-root \
        "$MAIN_USER_NAME:$MAIN_USER_GROUP_NAME" \
        /proc/self/fd/0 \
        /proc/self/fd/1 \
        /proc/self/fd/2 \
        &>/dev/null ||
    true
fi
set +x
command="$(eval "$COMMAND")"
if [[ "$command" != '' ]] && [[ "$command" != UNKNOWN ]]; then
    echo Run command \"$command\"
    if (( HOST_USER_ID == 0 )); then
        exec $command
    else
        exec su "$MAIN_USER_NAME" --group "$MAIN_USER_GROUP_NAME" -c "$command"
    fi
fi
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
