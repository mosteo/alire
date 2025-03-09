#!/usr/bin/bash

# Harden the script

trap 'echo "ERROR at line ${LINENO} (code: $?)" >&2' ERR
trap 'echo "Interrupted" >&2 ; exit 1' INT

set -o errexit
set -o nounset

# Build awsres from AWS only if awsres is not yet available here

if [ ! -f awsres ]; then
    workdir=$PWD
    tmp=$(mktemp -d)
    pushd "$tmp"

    alr get --build aws^24
    find . -name awsres -exec cp {} "$workdir" \;

    # Clean up
    popd
    rm -rf "$tmp"
fi

# Actually generate the embedded resources