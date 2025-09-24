#!/bin/bash

###############################################
#               Startup Script                #
###############################################

NIC=$1
echo "Using network interface: $NIC"

echo "Create Networks:"
docker network create -d macvlan \
  --subnet=192.168.1.0/25 \
  --gateway=192.168.1.1 \
  --aux-address 'host=192.168.1.126' \
  -o parent=$NIC \
  honeypotharbor-internal-network 

docker network create -d macvlan \
  --subnet=192.168.1.128/25 \
  --gateway=192.168.1.129 \
  --aux-address 'host=192.168.1.250' \
  -o parent=$NIC \
  honeypotharbor-attacker-network

echo "Create internal Macvlan shim for Host-access:"
sudo ip link add internal-net link $NIC type macvlan mode bridge
sudo ip addr add 192.168.1.126/25 dev internal-net 
sudo ip link set internal-net up
sudo ip route add 192.168.1.0/25 dev internal-net

echo "Create attacker Macvlan shim for Host-access:"
sudo ip link add attacker-net link $NIC type macvlan mode bridge
sudo ip addr add 192.168.1.254/25 dev attacker-net
sudo ip link set attacker-net up
sudo ip route add 192.168.1.128/25 dev attacker-net

echo "Prepare Cowrie directories and permissions..."
for i in 1 2 3; do
    sudo mkdir -p attacker-net/logs/cowrie$i
    sudo touch attacker-net/logs/cowrie$i/cowrie.json
    sudo chown -R $USER:999  attacker-net/logs/ attacker-net/cowrie-etc/
    sudo chmod -R 775 attacker-net/logs/ attacker-net/cowrie-etc/
done

echo "Startup Internal Network:"
docker compose -f internal-net/docker-compose.yml --env-file internal-net/internal.env up -d

echo "Startup Attacker Network:"
docker compose -f attacker-net/docker-compose.yml up -d

echo "Startup Gateway:"
docker compose -f gateway/docker-compose.yml up -d
