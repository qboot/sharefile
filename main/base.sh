#!/usr/bin/env bash

# VARIABLES

version=v0.1.0
relative_path=~/sharefile
config_file=$relative_path/.config
ssh_folder=$relative_path/.ssh
ssh_key=sharefile.key

if [ ! -f $config_file ]; then
    echo "Config file $config_file not found. Please run install/client.sh first."
    exit 1
fi

. $config_file

remote_folder=/home/$user/sharefile

# MAIN

local=$relative_path
remote=$user@$server:$remote_folder
