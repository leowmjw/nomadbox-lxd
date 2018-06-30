# build config
all: build

.PHONY: fmt
fmt:
	go fmt

.PHONY: build
build:
	go build -o ${GOPATH}/bin/mydemo

.PHONY: vet
vet:
	golint
	go vet --shadow

.PHONY: deps
deps:
	# Any deps to be here

.PHONY: tools
tools:
	# Get magefile here?

.PHONY: local-tools
local-tools:
	# Get nomad + consul for dev mode?
	# sshuttle inside a pipenv?