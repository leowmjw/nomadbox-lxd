# build config
# Courtesy of: https://www.cmcrossroads.com/article/setting-makefile-variable-outside-makefile
NOMAD_BOX_VERSION?=v0.1.0-lxd
NOMAD_BOX_VERSION_TERRAFORM=0.11.7
NOMAD_BOX_VERSION_CONSUL=1.2.0
NOMAD_BOX_VERSION_NOMAD=0.8.4
NOMAD_BOX_VERSION_VAULT=0.10.3
NOMAD_BOX_VERSION_HASHIUI=0.25.0
NOMAD_BOX_VERSION_TRAEFIK=1.6.4
NOMAD_BOX_VERSION_FABIO=1.5.9-go1.10.2
NOMAD_BOX_ENV?=env-development
NOMAD_BOX_NET?="10.0.0.0/16"
NOMAD_BOX_VAGRANT=/Users/leow/go/src/github.com/leowmjw/nomadbox-lxd
GOPATH=/home/vagrant/go

all: build

.PHONY: fmt
fmt:
	go fmt

.PHONY: vet
vet:
	golint
	go vet --shadow

.PHONY: build
build:
	# Compile the mydemo binary deployed with Nomad
	# Compile the magedemo binary to show higher-level binary
	cd ${GOPATH}/src/github.com/leowmjw/nomadbox-lxd && \
		go build -o ${GOPATH}/bin/mydemo && \
		mage -compile ${GOPATH}/bin/magedemo

.PHONY: deps
deps:
	# Any deps to be here
	# Get Magefile and set it up ..
	go get github.com/magefile/mage
	cd ${GOPATH}/src/github.com/magefile/mage && go run bootstrap.go

.PHONY: fix
fix: 
	# Fix the spike in netfilter .. make it permanent
	sudo cp /vagrant/etc/netfilter.cfg /etc/sysctl.d/99-netfilter.conf
	sudo sysctl -p

.PHONY: setup
setup:
	# Download consul, nomad, vault, terraform, traefik, hashiui, fabio
	# Done inside Vagrant so will be the Linux edition
	echo "Setting up Nomad Box (LXD Edition) in `pwd`!!!"

	echo "Downloading Hashi UI ${NOMAD_BOX_VERSION_HASHIUI}"
	cd bin && touch hashiui && rm hashiui* && \
		curl -L -O "https://github.com/jippi/hashi-ui/releases/download/v${NOMAD_BOX_VERSION_HASHIUI}/hashi-ui-linux-amd64" && \
		mv hashi-ui-linux-amd64 hashiui && chmod +x hashiui

	echo "Downloading Consul ${NOMAD_BOX_VERSION_CONSUL}"
	cd bin && touch consul && rm consul* && \
	  curl -L -O "https://releases.hashicorp.com/consul/${NOMAD_BOX_VERSION_CONSUL}/consul_${NOMAD_BOX_VERSION_CONSUL}_linux_amd64.zip" && \
	  unzip consul_${NOMAD_BOX_VERSION_CONSUL}_linux_amd64.zip

	echo "Downloading Nomad ${NOMAD_BOX_VERSION_NOMAD}"
	cd bin && touch nomad && rm nomad* && \
	  curl -L -O "https://releases.hashicorp.com/nomad/${NOMAD_BOX_VERSION_NOMAD}/nomad_${NOMAD_BOX_VERSION_NOMAD}_linux_amd64.zip" && \
	  unzip nomad_${NOMAD_BOX_VERSION_NOMAD}_linux_amd64.zip

	echo "Downloading Terraform ${NOMAD_BOX_VERSION_TERRAFORM}"
	cd bin && touch terraform && rm terraform* && \
	  curl -L -O "https://releases.hashicorp.com/terraform/${NOMAD_BOX_VERSION_TERRAFORM}/terraform_${NOMAD_BOX_VERSION_TERRAFORM}_linux_amd64.zip" && \
	  unzip terraform_${NOMAD_BOX_VERSION_TERRAFORM}_linux_amd64.zip

	echo "Downloading Vault ${NOMAD_BOX_VERSION_VAULT}"
	cd bin && touch vault && rm vault* && \
		curl -L -O "https://releases.hashicorp.com/vault/${NOMAD_BOX_VERSION_VAULT}/vault_${NOMAD_BOX_VERSION_VAULT}_linux_amd64.zip"  && \
		unzip vault_${NOMAD_BOX_VERSION_VAULT}_linux_amd64.zip

	echo "Downloading Fabio ${NOMAD_BOX_VERSION_FABIO}"
	cd bin && touch fabio && rm fabio* && \
		curl -L -O "https://github.com/fabiolb/fabio/releases/download/v${NOMAD_BOX_VERSION_FABIO}/fabio-${NOMAD_BOX_VERSION_FABIO}-go1.10.2-linux_amd64" && \
		mv fabio-${NOMAD_BOX_VERSION_FABIO}-go1.10.2-linux_amd64 fabio && \
		chmod +x fabio

	echo "Downloading Traefik ${NOMAD_BOX_VERSION_TRAEFIK}"
	cd bin && touch traefik && rm traefik* && \
		curl -L -O "https://github.com/containous/traefik/releases/download/v${NOMAD_BOX_VERSION_TRAEFIK}/traefik_linux-amd64" && \
		mv traefik_linux-amd64 traefik && chmod +x traefik

	# echo "Setup the proper modules .."
	# cd ./terraform/${NOMAD_BOX_ENV} && time ../../bin/terraform get -update
	# magedemo download
	# magedemo setupconfig

.PHONY: install
install:
	# ANything needed to be installed into the virtualenv can be here?
	
.PHONY: local-tools
local-tools:
	# Get nomad + consul for dev mode?
	# sshuttle inside a pipenv?

.PHONY: clean
clean:
	# Clean upo lxc environment before demo starts
	lxc delete -f f1 && lxc delete -f f2 && lxc delete -f f3  && lxc delete -f w1
	# TODO: Kill tmux session ..

.PHONY: start
start:
	# TODO: Encapsulate below into a tmux + tmuxp sessions probably

.PHONY: code
code:
	# Get code for things we'll want to play with 
	go get github.com/fabiolb/fabio 
	go get github.com/containous/traefik
	go get github.com/hashicorp/consul
	go get github.com/hashicorp/nomad
	go get github.com/hashicorp/vault

.PHONY: start-consul
start-consul:
	# Start the local consul agent which local dnsmasq refer to
	/vagrant/bin/consul agent -data-dir=/tmp/consul -retry-join=10.1.1.4 -retry-join=10.1.2.4 -retry-join=10.1.3.4 -bind=0.0.0.0 -disable-host-node-id -advertise=10.0.2.15 

.PHONY: start-hashiui
start-hashiui:
	# Get a local nomad binary for use to execute job; tie to magedemo?
	/vagrant/bin/hashiui --consul-enable -consul-address http://consul.service.consul:8500 --nomad-enable -nomad-address http://nomad.service.consul:4646

.PHONY: start-traefik
start-traefik:
	# Run traefik; assume config + binaries there ..
	sudo /vagrant/bin/traefik --configFile=/vagrant/etc/traefik.toml

