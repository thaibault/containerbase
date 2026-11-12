#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# region header
# [Project page](https://tsickert.com/containerbase)

# Copyright Torben Sickert (info["~at~"]tsickert.com) 16.12.2012

# License
# -------

# This library written by Torben Sickert stands under a creative commons naming
# 4.0 international license.
# See https://creativecommons.org/licenses/by/4.0/deed.de
# endregion
# Encrypts and decrypts a directory tree via "crypt", "encrypt" and "decrypt"
# and checks that the original content is restored. Runs without a container.
set -o errexit -o nounset -o pipefail

root_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work_path="$(mktemp --directory)"
trap 'gpgconf --kill gpg-agent &>/dev/null || true; rm --force --recursive "$work_path"' EXIT

fail() {
    echo "FAILED: $*" 1>&2
    exit 1
}
# region provide installed environment
# NOTE: The scripts source "get-bashlink" via "PATH" which looks for bashlink
# next to itself.
mkdir "${work_path}/bin"
ln --symbolic "${root_path}/scripts/get-bashlink.sh" "${work_path}/bin/get-bashlink"
ln --symbolic "${root_path}/node_modules" "${work_path}/bin/node_modules"
export PATH="${work_path}/bin:${PATH}"

export GNUPGHOME="${work_path}/gnupg"
mkdir --mode 700 "$GNUPGHOME"
# Collects all temporary files created by the scripts under test.
export TMPDIR="${work_path}/tmp"
mkdir "$TMPDIR"
# endregion
# region prepare fixtures
# NOTE: Glob characters, whitespaces and a ".gpg" within a directory name have
# to be handled literally.
plain_path="${work_path}/plain [1]/"
mkdir --parents "${plain_path}sub.gpg.d"
echo first >"${plain_path}file a.txt"
echo second >"${plain_path}sub.gpg.d/b.txt"
printf secret >"${work_path}/password"
# endregion
crypt="${root_path}/scripts/crypt.sh"
# region crypt with password file
"$crypt" \
    --password-file "${work_path}/password" \
    "$plain_path" \
    "${work_path}/encrypted/"
for file_path in 'file a.txt.gpg' sub.gpg.d/b.txt.gpg; do
    [ -s "${work_path}/encrypted/${file_path}" ] || \
        fail "Missing encrypted file \"${file_path}\"."
done
[ -e "${plain_path}file a.txt.gpg" ] && \
    fail Encrypted files were written into the source directory.

"$crypt" \
    --decrypt \
    --password-file "${work_path}/password" \
    "${work_path}/encrypted/" \
    "${work_path}/decrypted/"
diff --recursive "$plain_path" "${work_path}/decrypted/" || \
    fail Decrypted content differs from the original one.
# endregion
# region crypt with password
"$crypt" \
    --decrypt \
    --password secret \
    "${work_path}/encrypted/" \
    "${work_path}/decryptedWithPassword/"
diff --recursive "$plain_path" "${work_path}/decryptedWithPassword/" || \
    fail Decrypted content via password differs from the original one.

if "$crypt" \
    --decrypt \
    --password wrong \
    "${work_path}/encrypted/" \
    "${work_path}/decryptedWithWrongPassword/" \
        2>/dev/null
then
    fail Decrypting with a wrong password did not fail.
fi
# endregion
# region encrypt and decrypt via environment configuration
# NOTE: Path lists are configured as whitespace separated strings.
environment_plain_path="${work_path}/environmentPlain/"
cp --recursive "$plain_path" "$environment_plain_path"

export DECRYPT=true
export DECRYPTION_PASSWORD=secret
export DECRYPTED_PATHS="$environment_plain_path"
export ENCRYPTED_PATHS="${work_path}/environmentEncrypted/"
export ENVIRONMENT_FILE_PATHS=''
export PASSWORD_FILE_PATHS=''
export PASSWORD_SECRET_NAMES=''

pushd "$root_path" >/dev/null
bash ./scripts/encrypt.sh
[ -s "${ENCRYPTED_PATHS}file a.txt.gpg" ] || \
    fail Encrypting via environment configuration did not work.

DECRYPTED_PATHS="${work_path}/environmentDecrypted/" bash ./scripts/decrypt.sh
popd >/dev/null
diff --recursive \
    "$environment_plain_path" \
    "${work_path}/environmentDecrypted/" || \
    fail Decrypting via environment configuration did not work.

[ -z "$(ls --almost-all "$TMPDIR")" ] || \
    fail "Temporary files (e.g. passwords) were left: $(ls "$TMPDIR")"
# endregion
echo All crypt tests passed.
# region vim modline
# vim: set tabstop=4 shiftwidth=4 expandtab:
# vim: foldmethod=marker foldmarker=region,endregion:
# endregion
