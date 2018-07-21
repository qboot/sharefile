#!/usr/bin/env bash

# VARIABLES

version=v0.1.0
server=
default_user=sharefile
relative_path=~/sharefile
absolute_path=$( cd "$(dirname "$0")" ; pwd -P )
config_file=$relative_path/.config
ssh_folder=$relative_path/.ssh
ssh_key=sharefile.key
refresh=5 # each five minutes
cronjob="*/$refresh * * * * $absolute_path/../main/pull.sh > /dev/null 2>&1"
daemon_osx_name=com.sharefile
daemon_osx=$daemon_osx_name.plist

# TEXTS

welcome=$(cat <<EOM
sharefile client $version

Hello, thank you for using sharefile.
EOM
)

welcome_new=$( printf "Lets create your client config file!\n\r" )
welcome_existing=$( printf "You have already a configured installation.\n\r" )

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

create_cronjob() {
    file_tmp=crontab.tmp

    crontab -l 2>/dev/null > $file_tmp

    first_line=$(head -n1 $file_tmp)
    mailto="MAILTO=\"\""

    if [ "$first_line" != "$mailto" ]; then
        echo -e "$mailto\n$( cat $file_tmp )" > $file_tmp
    fi

    if ! grep -q -F "$cronjob" $file_tmp; then
        echo "$cronjob" >> $file_tmp
    fi

    crontab $file_tmp
    rm -f $file_tmp
}

create_daemon_linux() {
    echo TODO
}

create_daemon_osx() {
    launcher=~/Library/LaunchAgents
    input_file=$absolute_path/files/$daemon_osx
    output_file=$launcher/$daemon_osx
    startup_file=$absolute_path/../main/startup.sh
    log_file=$absolute_path/../logs/output.log
    error_file=$absolute_path/../logs/error.log

    sed "s^SCRIPT_PATH^$startup_file^g; s^OUTPUT_PATH^$log_file^g; s^ERROR_PATH^$error_file^g" $input_file > $output_file
    launchctl stop $daemon_osx_name && launchctl remove $daemon_osx_name
    launchctl load $output_file && launchctl start $daemon_osx_name
}

create_daemon() {
    case "$(uname -s)" in
        Linux* ) create_daemon_linux;;
        Darwin* ) create_daemon_osx;;
        *) exit 1;;
    esac
}

# MAIN

echo "$welcome"

# create sharefile folder
mkdir -p $relative_path

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

create_cronjob
create_daemon

exit 0
