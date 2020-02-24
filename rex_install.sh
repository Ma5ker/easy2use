#!/bin/bash
set -e

# This is a shell script for install the fucking rex v0.2 and its deps.
# For Ubuntu 16.04 LTS
# Rex and all deps source files will be in $HOME/rex_install folder
# note: use python 3.6+, or some modules may fail installation.


# step 0: get env
cur_user=$(env | grep USER | cut -d "=" -f 2)
profile_path=${HOME}/.profile
repo_path=$HOME/rex_install
tmp=$(python3 --version)
py_v=${tmp:7:3}
py_expect=3.6


# step 1:check user and py3 version
echo "[+]Check current user and python version..."
if [ $cur_user != "root" ]; then
    echo "Please execute it as root, exit."
    exit -1
fi

ck=`echo $py_v $py_expect | awk '{if($1 >= $2) print 1; else print 0;}'`
if [ $ck != 1 ]; then
    echo "python version lower than 3.6."
    exit -1
fi

# step 2: install virtualenv and some libs,echo > .profile
echo "[+]Install virtualenv and some libs"
apt-get install git python3-dev libffi-dev build-essential virtualenvwrapper -y
apt-get  build-dep qemu-system -y
apt-get install libacl1-dev -y
pip3 install --upgrade pip
pip3 install virtualenv
pip3 install virutalenvwrapper
echo "export WORKON_HOME=$HOME/.virtualenvs" >> $profile_path
echo "source /usr/local/bin/virtualenvwrapper.sh" >> $profile_path
source $profile_path

# step 3: clone dep repos and rex
mkdir $repo_path
cd $repo_path
echo "[+]Clone required repos..."
echo "[+]Cloning tracer..."
git clone https://github.com/angr/tracer.git
echo "[+]Cloning povsim..."
git clone https://github.com/mechaphish/povsim.git
echo "[+]Cloning wheels..."
git clone https://github.com/angr/wheels.git
echo "[+]Cloning compilerex..."
git clone https://github.com/mechaphish/compilerex.git
echo "[+]Cloning archr..."
git clone https://github.com/angr/archr.git
echo "[+]Cloning binaries..."
git clone https://github.com/angr/binaries.git
echo "[+]Cloning rex..."
git clone https://github.com/angr/rex.git

# step 4: intall dep module and rex
mkvirtualenv rex --python=$(which python3)
pip install --upgrade pip
pip install nose
pip install colorguard
pip install ipython
echo "[+]Installing some wheels..."
cd $repo_path/wheels
pip install shellphish_qemu-0.9.10-py3-none-manylinux1_x86_64.whl
pip install keystone_engine-0.9.1.post3-py2.py3-none-linux_x86_64.whl
echo "[+]Installing angr..."
pip install angr
echo "[+]Installing povsim..."
cd $repo_path/povsim
pip install .
echo "[+]Installing compilerex..."
cd $repo_path/compilerex
pip install .
echo "[+]Installing archr..."
cd $repo_path/archr
pip install .
echo "[+]Installing tracer..."
cd $repo_path/tracer
pip install .
echo "[+]Installing rex..."
cd $repo_path/rex
pip install .
echo "[*]Install Finished."

# step 5: call test_rex.py to test installation correctly
echo "[*]Testing rex with its script..."
script_path=$repo_path/rex/tests/test_rex.py
ipython script_path linux_stacksmash_32()
ipython script_path linux_stacksmash_64()
echo "[*]Testing finished."

