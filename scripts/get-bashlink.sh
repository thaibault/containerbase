#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# region header
# [Project page](https://torben.website/containerbase)

# Copyright Torben Sickert (info["~at~"]torben.website) 16.12.2012

# License
# -------

# This library written by Torben Sickert stand under a creative commons naming
# 3.0 unported license.
# See https://creativecommons.org/licenses/by/3.0/deed.de
# endregion
# shellcheck disable=SC1004,SC2016,SC2034,SC2155
shopt -s expand_aliases
alias br.download=br_download
br_download() {
    local -r __documentation__='
        Simply downloads missing modules.

        >>> br.download --silent https://domain.tld/path/to/file.ext; echo $?
        6
    '
    command curl --insecure "$@"
    return $?
}

if [ -f "$(dirname "${BASH_SOURCE[0]}")/node_modules/bashlink/module.sh" ]; then
    # shellcheck disable=SC1090
    source "$(dirname "${BASH_SOURCE[0]}")/node_modules/bashlink/module.sh"
elif [ -f "/usr/lib/bashlink/module.sh" ]; then
    # shellcheck disable=SC1091
    source "/usr/lib/bashlink/module.sh"
else
    declare -g BR_CACHE_PATH=/tmp/containerbaseInstallCache/
    declare -gr BL_MODULE_REMOTE_MODULE_CACHE_PATH="${BR_CACHE_PATH}bashlink"
    mkdir --parents "$BL_MODULE_REMOTE_MODULE_CACHE_PATH"
    declare -gr BL_MODULE_RETRIEVE_REMOTE_MODULES=true
    if ! (
        [ -f "${BL_MODULE_REMOTE_MODULE_CACHE_PATH}/module.sh" ] || \
        br.download \
            https://raw.githubusercontent.com/thaibault/bashlink/main/module.sh \
                >"${BL_MODULE_REMOTE_MODULE_CACHE_PATH}/module.sh"
    ); then
        echo Needed bashlink library could not be retrieved. 1>&2
        rm \
            --force \
            --recursive \
            "${BL_MODULE_REMOTE_MODULE_CACHE_PATH}/module.sh"
        exit 1
    fi
    # shellcheck disable=SC1091
    source "${BL_MODULE_REMOTE_MODULE_CACHE_PATH}/module.sh"
fi

bl.module.import bashlink.logging
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
