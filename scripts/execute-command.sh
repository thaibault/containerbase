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

if [[ "$*" != '' ]] && [[ "$*" != UNKNOWN ]]; then
    if (( HOST_USER_ID == 0 )); then
        echo Run command \"$*\" as root user.

        eval "$*"
        exit $?
    else
        echo \
            Run command \"$*\" as user \"$MAIN_USER_NAME\" in group \
            \"$MAIN_USER_GROUP_NAME\".

        exec su "$MAIN_USER_NAME" --group "$MAIN_USER_GROUP_NAME" -c "$*"
    fi
fi
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
