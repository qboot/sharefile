#!/usr/bin/env bash

# VARIABLES

version=v0.1.0
server=
default_user=sharefile
root=~/sharefile
config_file=$root/.config
ssh_folder=$root/.ssh
ssh_key=sharefile.key

# TEXTS

welcome=$(cat <<EOM
sharefile client $version

Hello, thank you for using sharefile.
EOM
)

welcome_new=$(cat <<EOM
Lets create your client config file!
!
EOM
); welcome_new=${welcome_new%!}

welcome_existing=$(cat <<EOM
You have already a configured installation.
!
EOM
); welcome_existing=${welcome_existing%!}

summary=$(cat <<EOM

Config file successfully created!
One final step before playing with fileshare...

Give your public key to your fileshare server administrator.
(or use it directly with push_key script if you have server root access)

Your key:
!
EOM
); summary=${summary%!}

# UTILS

create_ssh_key() {
    mkdir -p $ssh_folder
    touch $ssh_folder/$ssh_key
    yes y | ssh-keygen -t rsa -b 4096 -C "$user@sharefile.com" -N "" -f $ssh_folder/$ssh_key >/dev/null
    chmod 700 $ssh_folder && chmod 644 $ssh_folder/$ssh_key.pub && chmod 600 $ssh_folder/$ssh_key
}

create_config_file() {
    cat << EOF > $config_file
server=$server
user=$user
EOF
}

reset() {
    rm -rf $config_file $ssh_folder
}

# MAIN

echo "$welcome"

# create sharefile folder
mkdir -p $root

# check if config file exists
if [ -f $config_file ]; then
    echo "$welcome_existing"

    while true; do
        read -p "Do you want to reinstall sharefile (y/n) ?" choice
        case $choice in
            [Yy]* ) reset; break;;
            [Nn]* ) exit 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
fi

echo "$welcome_new"

# read parameters
while [[ $server = "" ]]; do
   read -p "Remote server*: " server
done
read -p "Remote user* [default: $default_user]: " user
user=${user:-$default_user}

create_ssh_key
create_config_file

echo "$summary"

cat $ssh_folder/$ssh_key.pub

exit 0
