#!/bin/bash

echo "Create Networks:"
docker network create honeypotharbor-internal-network
docker network create honeypotharbor-attacker-network

echo "Startup Internal Network:"
docker compose -f internal-net/docker-compose.yml --env-file internal-net/internal.env up --scale backend=3 --scale logstash=3 --scale frontend=2 -d

echo "Startup Attacker Network:"
docker compose -f attacker-net/docker-compose.yml --env-file attacker-net/attacker.env up -d

echo "Startup Gateway:"
docker compose -f gateway/docker-compose.yml up -d