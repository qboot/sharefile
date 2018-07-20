#!/usr/bin/env bash

# VARIABLES

version=v0.1.0
default_user=sharefile

# TEXTS

welcome=$(cat <<EOM
sharefile server $version

Hello, thank you for using sharefile.
Lets create your server config file!
!
EOM
); welcome=${welcome%!}

# UTILS

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Oops! Please run this script as root." 1>&2
        exit 1
    fi
}

create_user() {
    root=/home/$user

    adduser --disabled-password --gecos "" $user >& /dev/null
    mkdir -p $root/.ssh && touch $root/.ssh/authorized_keys
    chmod -R 700 $root && chmod 600 $root/.ssh/authorized_keys
    chown -R $user:$user $root
}

delete_user() {
    userdel -r $user >& /dev/null
}

create_sharefile_folder() {
    sudo -u $user mkdir -p /home/$user/sharefile
}

# MAIN

check_root

echo "$welcome"

# read parameters
read -p "New user* [default: $default_user]: " user
user=${user:-$default_user}

if id $user >/dev/null 2>&1; then
    if [ "$user" = "$default_user" ]; then
        while true; do
            printf "\nWARNING: It will delete all existing files in sharefile!\n"
            read -p "Do you want to delete user $user and reinstall sharefile (y/n) ?" choice
            case $choice in
                [Yy]* ) delete_user; break;;
                [Nn]* ) exit 1;;
                * ) echo "Please answer yes (y) or no (n).";;
            esac
        done
    else
        printf "\nUser %s already exist. Please use another username.\n" $user
        exit 1
    fi
fi

create_user
create_sharefile_folder

printf "\nUser %s successfully created! Sharefile server is ready to work. Well done!\n" $user
echo "You can now configure a sharefile client on a personal computer."

exit 0
