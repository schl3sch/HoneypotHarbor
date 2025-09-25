#!/bin/bash

###############################################
#       Startup Script Virtual Ethernet       #
###############################################

set -e

if ! ip link show veth0 &>/dev/null; then
  echo "Creating veth interface pair."
  sudo ip link add veth0 type veth peer name veth1
  sudo ip link set veth0 up
  sudo ip link set veth1 up
fi

echo "Create Networks."
docker network create -d macvlan \
  --subnet=192.168.1.0/25 \
  --gateway=192.168.1.1 \
  --aux-address 'host=192.168.1.126' \
  -o parent=veth0 \
  honeypotharbor-internal-network 

docker network create -d macvlan \
  --subnet=192.168.1.128/25 \
  --gateway=192.168.1.129 \
  --aux-address 'host=192.168.1.250' \
  -o parent=veth0 \
  honeypotharbor-attacker-network

echo "Create internal Macvlan shim for Host-access."
sudo ip link add internal-net link veth0 type macvlan mode bridge
sudo ip addr add 192.168.1.126/25 dev internal-net 
sudo ip link set internal-net up
sudo ip route add 192.168.1.0/25 dev internal-net

echo "Create attacker Macvlan shim for Host-access."
sudo ip link add attacker-net link veth0 type macvlan mode bridge
sudo ip addr add 192.168.1.254/25 dev attacker-net
sudo ip link set attacker-net up
sudo ip route add 192.168.1.128/25 dev attacker-net

echo "Prepare Cowrie directories and permissions."
for i in 1 2 3; do
    sudo mkdir -p attacker-net/logs/cowrie$i
    sudo touch attacker-net/logs/cowrie$i/cowrie.json
    sudo chown -R $USER:999 attacker-net/logs/ attacker-net/etc/
    sudo chmod -R 775 attacker-net/logs/ attacker-net/etc/
done

echo "Startup Internal Network."
docker compose -f internal-net/docker-compose.yml --env-file internal-net/internal.env up -d --build

echo "Startup Attacker Network."
docker compose -f attacker-net/docker-compose.yml up -d --build


echo "Startup Gateway."
docker compose -f gateway/docker-compose.yml up -d

echo "All networks and interfaces are setup."
