#!/bin/bash

###############################################
#    Shutdown Script for Wifi-only devices    #
###############################################

set -e

echo "Stopping Gateway."
docker compose -f gateway/docker-compose.yml down


echo "Stopping Attacker Network."
docker compose -f attacker-net/docker-compose.yml down

echo "Stopping Internal Network."
docker compose -f internal-net/docker-compose.yml --env-file internal-net/internal.env down

echo "Removing Networks."
docker network rm honeypotharbor-internal-network honeypotharbor-attacker-network

echo "Removing host macvlan interfaces and routes."
sudo ip route del 192.168.1.0/25 dev internal-net
sudo ip link set internal-net down
sudo ip link delete internal-net

sudo ip route del 192.168.1.128/25 dev attacker-net
sudo ip link set attacker-net down
sudo ip link delete attacker-net

echo "Removing veth interfaces."
if ip link show veth0 &>/dev/null; then
  sudo ip link set veth0 down
  sudo ip link delete veth0
fi

echo "All networks and interfaces cleaned up."