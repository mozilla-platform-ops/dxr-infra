#!/bin/bash
# downloads latest dxr.config from repo and indexes the given tree

# Grab the latest config
wget -q -O dxr.config https://github.com/klibby/dxr-docker/raw/rust/dxr.config

# hack: rust indexing is crazy memory intensive
if [ 'rust' == "$1" ]; then
    sed -i -e 's/^workers = ./workers = 2/' dxr.config
fi
exec venv/bin/dxr index -c dxr.config -v "$1"
