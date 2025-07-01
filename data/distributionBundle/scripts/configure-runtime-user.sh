#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# region header
# Copyright Torben Sickert (info["~at~"]torben.website) 16.12.2012

# License
# -------

# This library written by Torben Sickert stand under a creative commons naming
# 3.0 unported license. See https://creativecommons.org/licenses/by/3.0/deed.de
# endregion
# shellcheck disable=SC2155,SC2028
if (( UID != 0 )); then
    echo \
        Warning: You should bootstrap your container as root when using \
        configure runtime user. \
        1>&2
fi

export EXISTING_USER_GROUP_ID=$(id --group "$MAIN_USER_NAME")
export EXISTING_USER_ID=$(id --user "$MAIN_USER_NAME")

if [ "$HOST_USER_GROUP_ID" = '' ] || [ "$HOST_USER_GROUP_ID" = UNKNOWN ]; then
    export HOST_USER_GROUP_ID="$(
        stat --format '%g' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH"
    )"
fi
export HOST_USER_GROUP_NAME="$(
    getent group "$HOST_USER_GROUP_ID" | \
        cut --delimiter : --fields 1
)"

export USER_GROUP_ID_CHANGED=true
if (( EXISTING_USER_GROUP_ID == HOST_USER_GROUP_ID )); then
    export USER_GROUP_ID_CHANGED=false
fi

# region configure group
if (( HOST_USER_GROUP_ID == 0 )); then
    echo \
        Host user group id is 0 \(root\), ignoring user mapping and use root \
        as application group.

    export USER_GROUP_ID_CHANGED=false
    export MAIN_USER_GROUP_NAME=root
elif $USER_GROUP_ID_CHANGED; then
    echo \
        "Map container's existing user group id ${EXISTING_USER_GROUP_ID}" \
        "(\"${MAIN_USER_GROUP_NAME}\") from container's application user" \
        "\"${MAIN_USER_NAME}\" to host's group id ${HOST_USER_GROUP_ID}" \
        "(\"${HOST_USER_GROUP_NAME}\")."

    if [ "$HOST_USER_GROUP_NAME" = '' ]; then
        if \
            [ "$EXISTING_USER_GROUP_ID" = '' ] || \
            [ "$EXISTING_USER_GROUP_ID" = UNKNOWN ]
        then
            echo \
                Host user group id does not exist in container and container \
                does not have any application user group \
                "\"${MAIN_USER_GROUP_NAME}\". Creating corresponding user" \
                group and assign to the application user \
                "\"${MAIN_USER_NAME}\"."

            groupadd --gid "$HOST_USER_GROUP_ID" "$MAIN_USER_GROUP_NAME"
            usermod --gid "$HOST_USER_GROUP_ID" "$MAIN_USER_NAME"
        else
            echo \
                Host user group id does not exist in container and container \
                has already an application user group \
                "\"${MAIN_USER_GROUP_NAME}\". Changing corresponding user" \
                group id and assign to the application user \
                "\"${MAIN_USER_NAME}\"."

            groupmod --gid "$HOST_USER_GROUP_ID" "$MAIN_USER_GROUP_NAME"
        fi
    elif \
        [ "$EXISTING_USER_GROUP_ID" = '' ] || \
        [ "$EXISTING_USER_GROUP_ID" = UNKNOWN ]
    then
        echo \
            "Current application user \"${MAIN_USER_NAME}\" has no" \
            corresponding group and hosts one exists in container \
            "\"${HOST_USER_GROUP_NAME}\": assign it to them."

        usermod --gid "$HOST_USER_GROUP_ID" "$MAIN_USER_NAME"
        groupmod --new-name "$MAIN_USER_NAME" "$HOST_USER_GROUP_NAME"
    else
        echo \
            "Host user group id ${HOST_USER_GROUP_ID} could not be mapped" \
            into container since this group id is already used by application \
            "user group \"$HOST_USER_GROUP_NAME\"." \
                &>/dev/stderr
        sync

        exit 1
    fi
else
    echo \
        "Existing user group id ${EXISTING_USER_GROUP_ID} already matching" \
        the the containers one.
fi
# endregion
# region configure user
if [ "$HOST_USER_ID" = '' ] || [ "$HOST_USER_ID" = UNKNOWN ]; then
    export HOST_USER_ID="$(
        stat --format '%u' "$APPLICATION_USER_ID_INDICATOR_FILE_PATH"
    )"
fi

export HOST_USER_NAME="$(
    getent passwd "$HOST_USER_ID" | \
        cut --delimiter : --fields 1
)"

export USER_ID_CHANGED=true
if (( EXISTING_USER_ID == HOST_USER_ID )); then
    export USER_ID_CHANGED=false
fi

if (( HOST_USER_ID == 0 )); then
    echo \
        'Host user id is 0 (root), ignoring user mapping and use root as' \
        application user.

    export USER_ID_CHANGED=false
    export MAIN_USER_NAME=root
elif $USER_ID_CHANGED; then
    echo \
        "Map container's existing application user id ${EXISTING_USER_ID}" \
        "(\"${MAIN_USER_NAME}\") to host's user id ${HOST_USER_ID}" \
        "(\"${HOST_USER_NAME}\")."

    if [ "$HOST_USER_NAME" = '' ]; then
        if \
            [ "$EXISTING_USER_ID" = '' ] || [ "$EXISTING_USER_ID" = UNKNOWN ]
        then
            echo \
                Host user id does not exist in container and container does \
                "not have any application user \"${MAIN_USER_NAME}\"." \
                Creating corresponding user and assign id to them.

            useradd \
                --create-home \
                --gid "$HOST_USER_GROUP_ID" \
                --no-user-group \
                --uid "$HOST_USER_ID" \
                "$MAIN_USER_NAME"
        else
            echo \
                Host user group id does not exist in container and container \
                "has already an application user \"${MAIN_USER_NAME}\"." \
                Changing corresponding user id.

            usermod --uid "$HOST_USER_ID" "$MAIN_USER_NAME"
        fi
    elif [ "$EXISTING_USER_ID" = '' ] || [ "$EXISTING_USER_ID" = UNKNOWN ]; then
        echo \
            "Current application user \"${MAIN_USER_NAME}\" does not exist" \
            "but hosts one \"$HOST_USER_NAME\". Change corresponding user id" \
            to hosts one.

        usermod \
            --login "$MAIN_USER_NAME" \
            --uid "$HOST_USER_ID" \
            "$HOST_USER_NAME"
        usermod --home "/home/$MAIN_USER_NAME" --move-home "$MAIN_USER_NAME"
    else
        echo \
            "Host user id ${HOST_USER_ID} could not be mapped into container" \
            since this user id is already used by application user \
            "\"${HOST_USER_NAME}\"." \
                &>/dev/stderr

        exit 1
    fi
else
    echo \
        "Existing user id ${EXISTING_USER_ID} already matching the" \
        containers one.
fi

# Disable user account expiration.
for user_name in root "$MAIN_USER_NAME"; do
    chage --expiredate -1 "$user_name"
done
# endregion
# region hand over configured folder und files to configured user and group
for path in "$@"; do
    # If "true" we change ownership of all files. No matter who is currently
    # the owner.
    all=false
    # Change ownership of symbolically referenced source files also.
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

    find_command="find ${path} -xdev"

    # region handle group
    if $all; then
        echo \
            "Map file\'s group ownership in \"${path}\" to" \
            "\"${MAIN_USER_GROUP_NAME}\"."

        $find_command \
            -exec \
                chgrp \
                    --no-dereference \
                    --preserve-root \
                    "$MAIN_USER_GROUP_NAME" \
                    {} \
                    \;

        if $follow; then
            $find_command \
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
        $USER_GROUP_ID_CHANGED && \
        [[ "$EXISTING_USER_GROUP_ID" != '' ]] && \
        [[ "$EXISTING_USER_GROUP_ID" != UNKNOWN ]]
    then
        echo \
            "Map file\'s group ownership in \"${path}\" to" \
            "\"${MAIN_USER_GROUP_NAME}\"."

        $find_command \
            -group "$EXISTING_USER_GROUP_ID" \
            -exec \
                chgrp \
                    --no-dereference \
                    --preserve-root \
                    "$MAIN_USER_GROUP_NAME" \
                    {} \
                    \;

        if $follow; then
            $find_command \
                -group "$EXISTING_USER_GROUP_ID" \
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
    # endregion
    # region handle user
    if $all; then
        echo \
            "Map file\'s user ownership in \"${path}\" to" \
            "\"${MAIN_USER_NAME}\"."

        $find_command \
            -exec \
                chown \
                    --no-dereference \
                    --preserve-root \
                    "$MAIN_USER_NAME" \
                    {} \
                    \;

        if $follow; then
            $find_command \
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
        echo \
            "Map file\'s user ownership in \"${path}\" to" \
            "\"${MAIN_USER_NAME}\"."

        $find_command \
            -user "$EXISTING_USER_ID" \
            -exec \
                chown \
                    --no-dereference \
                    --preserve-root \
                    "$MAIN_USER_NAME" \
                    {} \
                    \;

        if $follow; then
            $find_command \
                -user "$EXISTING_USER_ID" \
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
    # endregion
done
# endregion
# region hand over common special files to configured user and group
if (( HOST_USER_GROUP_ID != 0 )) && (( HOST_USER_ID != 0 )); then
    chmod +x /dev/
    # NOTE: If you redirect the output of this "chown" command to "/dev/null"
    # you will end up in indeterministic behavior during accessing file
    # descriptors.
    if chown \
        --dereference \
        -H \
        --preserve-root \
        "$MAIN_USER_NAME:$MAIN_USER_GROUP_NAME" \
        /proc/self/fd/0 \
        /proc/self/fd/1 \
        /proc/self/fd/2
    then
        echo \
            Changing input and output file descriptors ownership to user \
            "\"${MAIN_USER_NAME}\" and group \"${MAIN_USER_GROUP_NAME}\"."
    else
        echo \
            Warning: Changing input and output file descriptors ownership to \
            "user \"${MAIN_USER_NAME}\" and group" \
            "\"${MAIN_USER_GROUP_NAME}\" did not work."
    fi
fi
# endregion
set +x
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
