#!/bin/bash
#
set -xe

# python3-virtualenv is not available on Trusty so install it here
sudo -E apt-get -y install python3-setuptools python3-dev python3-virtualenv

# create a virtualenv and install lxdock
python3 -m virtualenv -p python3 ~/venv
source ~/venv/bin/activate

# All action withhin the nomadbox-lxd repo folder; mounted in /vagrant
cd /vagrant

# Nothing to be intalled into the python virtualenv
# Can consider to abandon this and use direnv instead
# Maybe tmux + tmuxp here ..
# make install

# automatically activate virtualenv and switch to /vagrant on login
echo "source ~/venv/bin/activate" >> ~/.bashrc
echo "cd /vagrant" >> ~/.bashrc

# Setup go stuff and link to code ..
mkdir -p ${HOME}/go/{src,bin}
mkdir -p ${HOME}/go/src/github.com/leowmjw 

# Setup the needed code and bin path
ln -s /vagrant ${HOME}/go/src/github.com/leowmjw/nomadbox-lxd
export PATH=~/go/bin:$PATH

# Fix agressive netfilter
make fix
# Get all binaries
make deps
# TODO: Replace with Makefile instead
make build
# TODO: Setup tools, binaries + Prepare config
make setup 

# Go bin in the PATH! also /vagrant/bin for consul, nomad etc..
echo 'export PATH=~/go/bin:$PATH' >> ~/.bash_profile
echo 'export PATH=/vagrant/bin:$PATH' >> ~/.bash_profile

