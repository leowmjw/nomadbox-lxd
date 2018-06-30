# build config
all: build

.PHONY: fmt
fmt:
	go fmt

.PHONY: build
build:
	cd ${GOPATH}/github.com/leowmjw/nomadbox-lxd
	# Compile the mydemo binary deployed with Nomad
	go build -o ${GOPATH}/bin/mydemo
	# Compile the magedemo binary to show higher-level binary
	mage -compile ${GOPATH}/bin/magedemo

.PHONY: vet
vet:
	golint
	go vet --shadow

.PHONY: deps
deps:
	# Any deps to be here
	# Get Magefile and set it up ..
	go get github.com/magefile/mage
	cd ${GOPATH}/src/github.com/magefile/mage
	go run bootstrap.go

fix: 
	# Fix the spike in netfilter .. make it permanent

.PHONY: setup
setup:
	# Download consul, nomad, traefik, hashiui
	# magedemo download
	# magedemo setupconfig

.PHONY: local-tools
local-tools:
	# Get nomad + consul for dev mode?
	# sshuttle inside a pipenv?

.PHONY: start-consul
start-consul:
	# Start the local consul agent which local dnsmasq refer to
	consul agent -data-dir=/tmp/consul \ 
		-retry-join=10.1.1.4 -retry-join=10.1.2.4 -retry-join=10.1.3.4 \ 
		-bind=0.0.0.0 -disable-host-node-id -advertise=10.0.2.15 

.PHONY: start-hashiui
start-hashiui:
	# Get a local nomad binary for use to execute job; tie to magedemo?
	hashiui --consul-enable -consul-address http://consul.service.consul:8500 \
		--nomad-enable -nomad-address http://nomad.service.consul:4646

.PHONY: start-traefik
start-traefik:
	# Run traefik; assume config + binaries there ..
	traefik

