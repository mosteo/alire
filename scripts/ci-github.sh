#!/usr/bin/env bash

trap 'echo "ERROR at line ${LINENO} (code: $?)" >&2' ERR
trap 'echo "Interrupted" >&2 ; exit 1' INT

set -o errexit
set -o nounset

echo Default python version: $(python --version)
echo Pip version: $(pip --version)

python -c "import subprocess; subprocess.call('pwd')" || echo cd failed
