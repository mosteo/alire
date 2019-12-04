#!/bin/bash
# 
# This script regenerates the Ada sources for the corresponding templates 
# in ./templates/*. It should be run after any update to these files. It
# is intended to be run from the alire repository root folder.

set -o errexit

# Clean up any former files
rm -f src/alire/resources/*

# Generate embeddable files
awsres -a -o src/alire/resources -r alire_resources resources/*

# Fix reference to AWS, use EAT instead:
sed -i 's/AWS.Resources.Embedded/Eat/' src/alire/resources/alire_resources.adb

# Pretty print to avoid some warnings:
gnatpp --name-mixed-case src/alire/resources/*
