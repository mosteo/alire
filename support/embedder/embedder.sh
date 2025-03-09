#!/usr/bin/bash

# Harden the script

trap 'cleanup' EXIT
trap 'echo "ERROR at line ${LINENO} (code: $?)" >&2' ERR
trap 'echo "Interrupted" >&2 ; exit 1' INT

set -o errexit
set -o nounset

function cleanup {
    # Delete softlink if it is indeed a softlink
    [ -L templates ] && rm -f templates
}

# Build awsres from AWS only if awsres is not yet available here or in path

if [ ! -f awsres ] && ! command -v awsres &> /dev/null; then

    echo "Building awsres from AWS..."

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

export PATH+=":$PWD"

# Clean up old resources
[ -L templates ] && rm -f templates
rm -rf ../../src/templates
mkdir -p ../../src/templates

# Create a softlink to avoid .. paths that confuse awsres
ln -s ../../templates templates

# $ ./awsres -h
# AWSRes - Resource Creator v1.3

# Usage : awsres [-hopqrRzu] file1/dir1 [-zu] [file2/dir2...]

#         -a      : packages are named after the actual filenames
#         -o dir  : specify the output directory
#         -p str  : prefix all resource names with the given string
#         -R      : activate recursivity
#         -r name : name of the root package (default res)
#         -z      : enable compression of following resources
#         -u      : disable compression of following resources
#         -q      : quiet mode

awsres \
    -a \
    -o ../../src/templates \
    -R \
    -r r \
    -q \
    -z \
    templates

echo "Resources created successfully"