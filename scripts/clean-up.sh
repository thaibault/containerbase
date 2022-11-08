#!/usr/bin/bash
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
# shellcheck disable=SC1091,SC2016,SC2034,SC2155
bin=pacman
if hash yay &>/dev/null; then
    bin=yay
fi

if [ "$($bin --query --deps --unrequired --quiet)" = '' ]; then
   $bin --remove --sync --nosave $($bin --query --deps --unrequired --quit)
fi

# NOTE: We should avoid leaving unnecessary data in that layer.
rm /var/cache/* --recursive --force
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
