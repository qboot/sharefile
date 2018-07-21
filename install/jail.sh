#!/usr/bin/env bash

# VARIABLES

version=v0.1.0
jail_dir=/jail
user=$1
sshd_config=/etc/ssh/sshd_config

# TEXTS

ssh_chroot=$( cat <<EOM

Match User $user
    ChrootDirectory $jail_dir/
    X11Forwarding no
    AllowTcpForwarding no
EOM
)

profile=$( cat <<EOM
if [ "$BASH" ]; then
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
fi
EOM
)

# UTILS

create_user() {
    home_path=/home/$user

    useradd -d $home_path -s /bin/bash $user >& /dev/null
    mkdir -p $home_path/.ssh && touch $home_path/.ssh/authorized_keys

    # create chroot home
    mkdir -p $jail_dir/home/$user
    cat /etc/passwd | grep $user >> $jail_dir/etc/passwd

    # add .bashrc and .profile for nice prompt
    echo "export PS1='\u@\h:\w\$ '" > $jail_dir/home/$user/.bashrc
    echo "$profile" > $jail_dir/home/$user/.profile
}

create_sharefile_folder() {
    sharefile_dir=$jail_dir/home/$user/sharefile
    mkdir -p $sharefile_dir && chown -R $user:$user $sharefile_dir
}

# MAIN

if [ -d "$jail_dir" ]; then
    echo "Jail already exist!"
    exit 1
fi

# jail directories
mkdir -p $jail_dir/{dev,etc,lib,lib64,usr/bin,bin}

# null device node
mknod -m 666 $jail_dir/dev/null c 1 3

# required files
cp /etc/ld.so.{cache,conf} $jail_dir/etc/
cp /etc/nsswitch.conf $jail_dir/etc/
cp /etc/hosts $jail_dir/etc/

# add ls, bash, rsync commands
cp /bin/bash $jail_dir/bin/bash
cp /bin/ls $jail_dir/bin/ls
cp $( which rsync ) $jail_dir/bin/rsync

# FHS requires /bin/sh exists
pushd $jail_dir/bin/
ln -s bash sh
popd

# l2chroot script lets us copy library dependencies easier
wget -O /usr/local/sbin/l2chroot http://www.cyberciti.biz/files/lighttpd/l2chroot.txt
chmod 744 /usr/local/sbin/l2chroot
sed -i "s@/webroot@$jail_dir@" /usr/local/sbin/l2chroot

# copy library dependencies with l2chroot
l2chroot /bin/bash
l2chroot /bin/ls
l2chroot $( which rsync )

# additional dependencies for displaying the name of our user in its prompt
cp /lib/x86_64-linux-gnu/libnsl.so.1 $jail_dir/lib/x86_64-linux-gnu/
cp /lib/x86_64-linux-gnu/libnss_* $jail_dir/lib/x86_64-linux-gnu/

# append chroot to sshd_config
echo "$ssh_chroot" >> $sshd_config
systemctl restart ssh

create_user
create_sharefile_folder
