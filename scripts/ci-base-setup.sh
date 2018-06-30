#!/bin/bash
#
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

sudo -E apt-get update -q
sudo -E apt-get purge -y lxd lxd-client 

# Install the needed deps like snapd + zfsutils-linux + gcc (for dev env, cgo)
sudo -E apt-get install -y snapd zfsutils-linux gcc g++

sudo snap install lxd
# INstall golang below so we can compile anything needed in Linux itself
sudo snap install --classic go
sudo snap list
sudo lxd --version
sudo snap start lxd

export PATH="/snap/bin:$PATH"

# lxd waitready times out
while [ ! -S /var/snap/lxd/common/lxd/unix.socket ]; do
  sleep 0.5
done

user=`whoami`
sudo usermod -a -G lxd ${user}

# Setup for configuring the network
mkdir -p ${HOME}/my-zfs-pool
dd if=/dev/zero of=${HOME}/my-zfs-pool/zfs.img bs=1k count=1 seek=100M && \
  sudo zpool create my-zfs-pool ${HOME}/my-zfs-pool/zfs.img

echo "Setting up LXD .."
# Init LXD as per in docs ...
cat <<EOF | lxd init --verbose --preseed
# Daemon settings
config:
  core.https_address: 0.0.0.0:9999
  core.trust_password: passw0rd
  images.auto_update_interval: 36

# Storage pools
storage_pools:
- name: data
  driver: zfs
  config:
    source: my-zfs-pool/my-zfs-dataset

# Network devices
networks:
- name: lxdbr0
  type: bridge
  config:
    ipv4.address: auto
    ipv6.address: none

# Profiles
profiles:
- name: default
  devices:
    root:
      path: /
      pool: data
      type: disk
EOF

# ansible test needs ssh
if [ ! -f $HOME/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 2048 -f $HOME/.ssh/id_rsa -P ""
fi

# allows testing shares with raw.idmap
printf "lxd:$(id -u):1\nroot:$(id -u):1\n" | sudo tee -a /etc/subuid
printf "lxd:$(id -g):1\nroot:$(id -g):1\n" | sudo tee -a /etc/subgid
sudo snap restart lxd
