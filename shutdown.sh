#!/bin/bash

echo "Stopping Gateway:"
docker compose -f gateway/docker-compose.yml down

echo "Stopping Attacker Network:"
docker compose -f attacker-net/docker-compose.yml --env-file attacker-net/attacker.env down

echo "Stopping Internal Network:"
docker compose -f internal-net/docker-compose.yml --env-file internal-net/internal.env down

echo "Removing Networks:"
docker network rm honeypotharbor-internal-network honeypotharbor-attacker-network

echo "All services stopped and networks removed."