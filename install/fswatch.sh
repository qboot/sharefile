#!/usr/bin/env bash

mkdir -p /opt/fswatch && cd /opt/fswatch
wget https://github.com/emcrisostomo/fswatch/releases/download/1.9.3/fswatch-1.9.3.tar.gz
tar -xvzf fswatch-1.9.3.tar.gz
cd fswatch-1.9.3
./configure
make
sudo make install
sudo ldconfig
