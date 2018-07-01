#!/bin/bash
#
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Setup base network; inside 10.1.{1,2,3}.1/24 subnet; representing ap-southeast-{a,b,c}
lxc network create fsubnet1 ipv6.address=none ipv4.address=10.1.1.1/24 ipv4.nat=true
lxc network create fsubnet2 ipv6.address=none ipv4.address=10.1.2.1/24 ipv4.nat=true
lxc network create fsubnet3 ipv6.address=none ipv4.address=10.1.3.1/24 ipv4.nat=true

# DNSMasq can be setup to add additional raw entries ..
# Assumes consul is running inside the Vagrant machine
echo -e "server=/consul/127.0.0.1#8600\nrev-server=10.0.0.0/8,127.0.0.1#8600" | lxc network set fsubnet1 raw.dnsmasq -
echo -e "server=/consul/127.0.0.1#8600\nrev-server=10.0.0.0/8,127.0.0.1#8600" | lxc network set fsubnet2 raw.dnsmasq -
echo -e "server=/consul/127.0.0.1#8600\nrev-server=10.0.0.0/8,127.0.0.1#8600" | lxc network set fsubnet3 raw.dnsmasq -

# lxc image list images: | grep bionic
# Also have "lxc image list ubuntu-daily: + lxc image list ubuntu:"
# How to copy the i,age and get it going .. with alias for bionic ..
# Pull 18.04 and latest; have options to select ..
lxc image copy images:alpine/edge local: --alias=alpine
# Below does not have cloud-init so does NOT help us ..
# lxc image copy images:ubuntu/18.04 local: --alias=bionic
lxc image copy ubuntu:18.04 local: --alias=bionic

# Use the Ubuntu nodes so can run cloud-init??
lxc profile create foundation
# Need to provide the cloud-init.sh scripts ..
lxc profile set foundation user.user-data - < /vagrant/scripts/lxd-foundation-init.sh

# Use the Ubuntu nodes so can run cloud-init??
lxc profile create worker
# Need to provide the cloud-init.sh scripts ..
lxc profile set worker user.user-data - < /vagrant/scripts/lxd-worker-init.sh

# Setup from scratch the foundation nodes ..
# lxc delete -f f1 && lxc delete -f f2 && lxc delete -f f3  && lxc delete -f w1

# Exec in and confirm it is running
lxc init bionic -p default -p foundation f1 && \
    lxc network attach fsubnet1 f1 eth0 && \
    lxc config device set f1 eth0 ipv4.address 10.1.1.4

lxc init bionic -p default -p foundation f2 && \
    lxc network attach fsubnet2 f2 eth0 && \
	lxc config device set f2 eth0 ipv4.address 10.1.2.4

lxc init bionic -p default -p foundation f3 && \
    lxc network attach fsubnet3 f3 eth0 && \
	lxc config device set f3 eth0 ipv4.address 10.1.3.4

# NOTE: security.nesting=true is needed to run Docker inside of LXC container :P
lxc init bionic -p default -p worker w1 && \
    lxc network attach fsubnet1 w1 eth0 && \
    lxc config device set w1 eth0 ipv4.address 10.1.1.100 && \
    lxc config device add w1 sharedtmp disk path=/tmp/shared source=/vagrant

lxc start f1 && lxc start f2 && lxc start f3 && lxc start w1

# Had problem setting uo when not have docker there yet; deps?
# lxc config set w1 security.nesting=true && \

# Likely should start with the exec of kickoff script .. maybe ..
# cloud-init just to install; start/stop with setup for running consul/nomad?
# Or in this case maybe clean always? .. shoukd just use systemd services ..

# Setup Directors

# Setup Workers
# Setup base network .. (not needed share with foundation)
# lxc network create wsubnet1 ipv6.address=none ipv4.address=10.1.10.1/24 ipv4.nat=true
# lxc network create fsubnet2 ipv6.address=none ipv4.address=10.1.2.1/24 ipv4.nat=true
# lxc network create fsubnet3 ipv6.address=none ipv4.address=10.1.3.1/24 ipv4.nat=true

# DNSMasq can be setup to add additional raw entries ..
# Below can be an option to pass dhcp options; but need to modifyu systemd ..
# echo -e "dhcp-option=6,10.1.1.1,1.1.1.1,8.8.8.8\nserver=/consul/10.1.1.4#8600\nrev-server=10.0.0.0/8,10.1.1.4#8600" | lxc network set fsubnet1 raw.dnsmasq -
# echo -e "server=/consul/10.1.10.100#8600\nrev-server=10.0.0.0/8,10.1.10.100#8600" | lxc network set wsubnet1 raw.dnsmasq -
# echo -e "server=/consul/10.1.2.4#8600\nrev-server=10.0.0.0/8,10.1.2.4#8600" | lxc network set fsubnet2 raw.dnsmasq -
# echo -e "server=/consul/10.1.3.4#8600\nrev-server=10.0.0.0/8,10.1.3.4#8600" | lxc network set fsubnet3 raw.dnsmasq -

# Setup from scratch the worker nodes ..
# lxc delete -f w1 && lxc delete -f w2 && lxc delete -f w3 

# Exec in and confirm it is running
# lxc init bionic -p default -p worker w1 && \
#     lxc network attach wsubnet1 w1 eth0 && \
#     lxc config device set w1 eth0 ipv4.address 10.1.10.100 && \
#     lxc config device add w1 sharedtmp disk path=/tmp/shared source=/vagrant/playground-nomad

# lxc init bionic -p default -p worker w2 && \
#     lxc network attach fsubnet2 f2 eth0 && \
# 	lxc config device set f2 eth0 ipv4.address 10.1.2.100

# lxc init bionic -p default -p worker w3 && \
#     lxc network attach fsubnet3 f3 eth0 && \
# 	lxc config device set f3 eth0 ipv4.address 10.1.3.100

# lxc start w1 
# && lxc start w2 && lxc start w3

# Setup Experimental

# Final step below is needed
# chown -R testadmin:testadmin /home/testadmin/.config
