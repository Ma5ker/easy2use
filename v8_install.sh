#!/bin/sh

#
# script for compile the v8 engine of google
# all source code will be in $HOME/v8_workspace

wk_path=$HOME/v8_workspace
tool_path=$wk_path/tool
v8_ipath=$wk_path/v8
v8_path=$wk_path/v8/v8
v8gen=$wk_path/v8/v8/tools/dev/v8gen.py

version=6.0

mkdir $wk_path
mkdir $tool_path
mkdir $v8_path

# install depot_tools
sudo apt install -y git
cd $tool_path
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
echo "export PATH=$tool_path/depot_tools:\$PATH" >> $HOME/.profile
source $HOME/.profile
gclient

# get v8 source code
cd $v8_ipath
fetch v8
echo "alias v8gen=$v8gen" >> $HOME/.bashrc
source $HOME/.bashrc
cd $v8_path/build
./install-build-deps.sh
cd $v8_path

# change version 
git checkout branch-heads/$version
cd $v8_ipath
gclient sync

# compile v8
cd $v8_path
v8gen x64.release
ninja -C out.gn/x64.release

#finish.


