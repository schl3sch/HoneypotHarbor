#!/bin/bash

###############################################
#              Shutdown Script                #
###############################################

set -e

echo "Stopping Gateway."
docker compose -f gateway/docker-compose.yml down

echo "Stopping Attacker Network."
docker compose -f attacker-net/docker-compose.yml down

echo "Stopping Internal Network."
docker compose -f internal-net/docker-compose.yml  --env-file internal-net/internal.env down

echo "Removing Networks."
docker network rm honeypotharbor-internal-network honeypotharbor-attacker-network


echo "Removing host macvlan interfaces and routes."

# Internal network
sudo ip route del 192.168.1.0/25 dev internal-net
sudo ip link set internal-net down
sudo ip link delete internal-net

# Attacker network
sudo ip route del 192.168.1.128/25 dev attacker-net
sudo ip link set attacker-net down
sudo ip link delete attacker-net

echo "All networks and interfaces cleaned up."