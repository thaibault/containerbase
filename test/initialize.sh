#!/usr/bin/bash
# -*- coding: utf-8 -*-
set -e
# 1. Checks if newer initialier is bind into container and exec into to if
# present.
# 2. Loads environment files if existing.
# 3. Decrypt configured locations if specified.
source prepare-initializer "$@"
echo Application started. Shutting down in 3 sec...
sleep 3
