#!/usr/bin/env bash

# VARIABLES

version=v0.1.0
root=~/sharefile
config_file=$root/.config
sudo_user=
ssh_key=

if [ ! -f $config_file ]; then
    echo "Config file $config_file not found. Please run install/client.sh first."
    exit 1
fi

. $config_file

remote_file=/home/$user/.ssh/authorized_keys

# TEXTS

welcome=$(cat <<EOM
sharefile push_key utility $version

Hello, thank you for using sharefile.
You need root access to $server server to run this script.
!
EOM
); welcome=${welcome%!}

# UTILS

check_remote_file() {
    if ! ssh $sudo_user@$server stat $remote_file \> /dev/null 2\>\&1; then
        printf "\nRemote file %s doesn't exist on server %s.\n" $remote_file $server
        exit 1
    fi
}

# MAIN

echo "$welcome"

# read parameters
while [[ $sudo_user = "" ]]; do
   read -p "Remote user with root access*: " sudo_user
done
while [[ $ssh_key = "" ]]; do
   read -p "New SSH public key to add*: " ssh_key
done

check_remote_file

if ! ssh $sudo_user@$server "grep -q -F '$ssh_key' $remote_file"; then
    ssh $sudo_user@$server "echo '$ssh_key' >> $remote_file"
fi

printf "\nSSH public key successfully added!\n"
