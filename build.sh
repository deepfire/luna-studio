#!/bin/bash

source "dist/shell.sh"

# ensure that all the requirements are satisfied:
pip3 install --user -r requirements.txt > /dev/null 2>&1
python3 build/build.py "$@"
