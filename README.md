# sharefile

*sharefile* is a Dropbox-like open-source utility written in bash.

It synchronizes a local **sharefile** folder with a remote one using `rsync` and `ssh`.

## Requirements

- A *nix server with root access and enough disk space.
- [fswatch](https://github.com/emcrisostomo/fswatch) on your personal computer (for `sharefile-client`).

```bash
# for OS X users
$ brew install fswatch
```

```bash
# for Linux users (ONLY)

# install development tools
$ yum group install 'Development Tools' # on CentOS/RHEL
$ dnf group install 'Development Tools'	# on Fedora 22+ Versions
$ sudo apt-get install build-essential  # on Debian/Ubuntu Versions

# then run installation script
$ sudo ./install/fswatch.sh
```

## Installation

*sharefile* works with only 3 quick steps.

### Step 1 - Install sharefile-server

On your server, run the following commands (with root):

```bash
$ git clone git@github.com:qboot/sharefile.git
$ sudo ./sharefile/install/server.sh
```

### Step 2 - Install sharefile-client

On your personal computer, run the following commands:

> :warning: Please choose a good location before running `git clone`.
> You should not move or delete *sharefile* application folder after installation.

```bash
$ git clone git@github.com:qboot/sharefile.git
$ ./sharefile/install/client.sh
```

### Step 3 - Add SSH authorized keys

On admin personal computer, run the following commands:

```bash
# if you have root access to remote sharefile server
$ git clone git@github.com:qboot/sharefile.git
$ ./sharefile/install/ssh.sh

# if not, just give your public key to the administrator and ask him to add it
```

## Usage

There is a new directory under your `$HOME` called `sharefile`.

```bash
$ cd ~/sharefile #here
```

Each 5 minutes *sharefile* pulls all new files from remote server.
When you add a file|directory, *sharefile* pushes it instantly to remote server.

Have fun! :v:
