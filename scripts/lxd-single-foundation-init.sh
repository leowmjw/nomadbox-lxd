#!/bin/bash
#
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# This should be filled in by TF template using the Makefile ENV
NOMAD_BOX_VERSION_CONSUL=1.2.0
NOMAD_BOX_VERSION_NOMAD=0.8.4
# NOMAD_BOX_VERSION_NOMAD_UI=0.13.4

# Get the basic packages
export DEBIAN_FRONTEND=noninteractive && apt-get update \
    && apt-get upgrade -y && \
    apt-get install -y unzip 

# Setup resolved in systemd to use Consul if possible ..
cat > /etc/systemd/resolved.conf  <<EOF
[Resolve]
  DNS=10.1.1.1 10.1.2.1 10.1.3.1
  FallbackDNS=1.1.1.1 8.8.8.8
  Domains=~consul
EOF

systemctl restart systemd-resolved

# Consul operates in /opt
# ========================
mkdir -p /opt/consul
cd /opt/consul

# Get the binaries
wget "https://releases.hashicorp.com/consul/${NOMAD_BOX_VERSION_CONSUL}/consul_${NOMAD_BOX_VERSION_CONSUL}_linux_amd64.zip"
unzip consul_${NOMAD_BOX_VERSION_CONSUL}_linux_amd64.zip

# Extract the IP address from the determined interface
HOST_INTERFACE="eth0"
IP_ADDRESS=$(ip -o -4 addr list $HOST_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
echo "Discovered IP Address: ${IP_ADDRESS}"

# With the attached templates; put in the needed variables
# Location mounted: /tmp/shared/templates
# Set IP Address in config
sed "s/##HOST_IP##/${IP_ADDRESS}/g" < /tmp/shared/templates/consul_conf.hcl.tmpl > consul.hcl

# Create logs folder if needed
if [ ! -d "/opt/log" ]; then
  mkdir /opt/log
fi

# Start Consul
echo "Starting Consul Server, redirecting logs to ./log/consul.log"
nohup ./consul agent -config-file=consul.hcl -retry-join=10.1.1.4  -retry-join=10.1.2.4 -retry-join=10.1.3.4 -node-meta "type:foundation" -node-meta "class:primary" >/opt/log/consul.log 2>&1 &
# Below not needed, use source_nomad ..
# export CONSUL_HTTP_ADDR=http://${IP_ADDRESS}:8500

# TODO: Use the /tmp/shared/etc/consul.service to ensure it restarts at will ..
  # 108  cp consul.service /etc/systemd/system/.
  # 109  systemctl enable consul.service
  # 110  systemctl start consul.service

# Setup Nomad (must run as root) ..
# ====================================
# Nomad operates in /opt
mkdir -p /opt/nomad
cd /opt/nomad

# Get the binaries
wget "https://releases.hashicorp.com/nomad/${NOMAD_BOX_VERSION_NOMAD}/nomad_${NOMAD_BOX_VERSION_NOMAD}_linux_amd64.zip"
unzip nomad_${NOMAD_BOX_VERSION_NOMAD}_linux_amd64.zip

# Start Nomad
sed "s/##HOST_IP##/${IP_ADDRESS}/g" < /tmp/shared/templates/nomad_conf.hcl.tmpl > nomad.hcl
echo "Starting Nomad Server, redirecting logs to /opt/log/nomad.log"
nohup ./nomad agent --config=nomad.hcl  >/opt/log/nomad.log 2>&1 &

  # 108  cp nomad.service /etc/systemd/system/.
  # 109  systemctl enable nomad.service
  # 110  systemctl start nomad.service

# Set Nomad environment variable
# Below not needed, use source_nomad ..
# export NOMAD_ADDR=http://${IP_ADDRESS}:4646

