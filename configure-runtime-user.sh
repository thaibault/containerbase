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
OLD_GROUP_ID=\$(id --group \"\$MAIN_USER_NAME\")
OLD_USER_ID=\$(id --user \"\$MAIN_USER_NAME\")
GROUP_ID_CHANGED=false
if [ \"\$HOST_GID\" = '' ]; then
    HOST_GID=\"\$(stat --format '%g' \"\$APPLICATION_USER_ID_INDICATOR_FILE_PATH\")\"
fi
if [[ \$OLD_GROUP_ID != \$HOST_GID ]]; then
    echo \"Map group id \$OLD_GROUP_ID from application user \$MAIN_USER_NAME to host group id \$HOST_GID from \$(stat --format '%G' \"\$APPLICATION_USER_ID_INDICATOR_FILE_PATH\").\"
    usermod --gid \"\$HOST_GID\" \"\$MAIN_USER_NAME\"
    GROUP_ID_CHANGED=true
fi
if [ \"\$HOST_UID\" = '' ]; then
    HOST_UID=\"\$(stat --format '%u' \"\$APPLICATION_USER_ID_INDICATOR_FILE_PATH\")\"
fi
USER_ID_CHANGED=false
if [[ \$OLD_USER_ID != \$HOST_UID ]]; then
    echo \"Map user id \$OLD_USER_ID from application user \$MAIN_USER_NAME to host user id \$HOST_UID from \$(stat --format '%U' \"\$APPLICATION_USER_ID_INDICATOR_FILE_PATH\").\"
    usermod --uid \"\$HOST_UID\" \"\$MAIN_USER_NAME\"
    USER_ID_CHANGED=true
fi
# TODO do this for given paths!
if \$GROUP_ID_CHANGED; then
    find \"\$TEMPORARY_NGINX_PATH\" -xdev -group \$OLD_GROUP_ID -exec chgrp --no-dereference \$MAIN_USER_GROUP_NAME {} \\;
    find ./ -xdev -group \$OLD_GROUP_ID -exec chgrp --no-dereference \$MAIN_USER_GROUP_NAME {} \\;
fi
if \$USER_ID_CHANGED; then
    find \"\$TEMPORARY_NGINX_PATH\" -xdev -user \$OLD_USER_ID -exec chown --no-dereference \$MAIN_USER_NAME {} \\;
    find ./ -xdev -user \$OLD_USER_ID -exec chown --no-dereference \$MAIN_USER_NAME {} \\;
fi
chmod +x /dev/
chown --dereference -L \$MAIN_USER_NAME:\$MAIN_USER_GROUP_NAME /proc/self/fd/0 /proc/self/fd/1 /proc/self/fd/2
set +x
exec su \$MAIN_USER_NAME --group \$MAIN_USER_GROUP_NAME -c \"[ ! -f '\${APPLICATION_PATH}/magnolia/'*-webapp/target/*.war ] && npm run build; npm run \$COMMAND\"
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
