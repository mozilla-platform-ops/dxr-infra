#!/bin/bash
# downloads latest dxr.config from repo and indexes the given tree

# Grab the latest config
wget -q -O dxr.config https://github.com/klibby/dxr-docker/raw/master/dxr.config

exec venv/bin/dxr index -c dxr.config -v "$1"
