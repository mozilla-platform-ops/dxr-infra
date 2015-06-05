#!/bin/bash

set -e

if [ ! -d venv ]; then
    virtualenv venv
fi

source venv/bin/activate
pip install --upgrade pip
pip install --upgrade -r requirements.txt

