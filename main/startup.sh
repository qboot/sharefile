#!/usr/bin/env bash

PATH="/usr/local/bin:${PATH}"

# VARIABLES

version=v0.1.0
relative_path=~/sharefile
absolute_path=$( cd "$(dirname "$0")" ; pwd -P )
push_file=$absolute_path/push.sh

if [ ! -f $push_file ]; then
    echo "Push file $push_file not found."
    exit 1
fi

# MAIN

fswatch --print0 --recursive --one-per-batch --access $relative_path | xargs -0 -n 1 $push_file
