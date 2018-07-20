#!/usr/bin/env bash

absolute_path=$( cd "$(dirname "$0")" ; pwd -P )
base_file=$absolute_path/base.sh

if [ ! -f $base_file ]; then
    echo "Base file $base_file not found."
    exit 1
fi

. $base_file

rsync -az -e "ssh -i $ssh_folder/$ssh_key" --exclude .ssh --exclude .config --exclude .DS_Store $local/ $remote
