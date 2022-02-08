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
command="$(eval "echo $COMMAND")"
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
