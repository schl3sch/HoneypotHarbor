#!/bin/bash

echo "Generating testlogs..."
cp ./prepared_testlogs.json ../attacker-net/logs/testlogs/testlogs.json 
echo "Testlogs have been generated. It may take a short while for them to appear in Elasticsearch."
