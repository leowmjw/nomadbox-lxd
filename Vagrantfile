# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant file to setup a vagrant box for running lxdock tests locally,
# requires Vagrant 1.8.5+ for the bento image. Run "make coverage" inside box.

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"

  config.vm.network "public_network"
  # Forward the ports for Traefik LB + UI, HashiUI, Consul, Vault, Nomad, GoBetween, Fabio, VaultUI  
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 8081, host: 8081
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.network "forwarded_port", guest: 8500, host: 8500
  config.vm.network "forwarded_port", guest: 8200, host: 8200
  config.vm.network "forwarded_port", guest: 4646, host: 4646
  config.vm.network "forwarded_port", guest: 9997, host: 9997
  config.vm.network "forwarded_port", guest: 9998, host: 9998
  config.vm.network "forwarded_port", guest: 9988, host: 9988

  # Map the current folder into the code for use in Vagrant + LXC containers
  # Below is not needed as current folder auto mounted to /vagrant
  # config.vm.synced_folder ".", "/code"

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    # vb.gui = true
    # Customize the amount of memory on the VM:
    vb.memory = "3068"
  end

  # config.vm.provision "shell", path: "scripts/ci-base-setup.sh", privileged: false
  config.vm.provision "shell", path: "scripts/vagrant-base-setup.sh", privileged: false
  config.vm.provision "shell", path: "scripts/lxd-base-setup.sh", privileged: false
end
