#!/bin/bash

containers=("192.168.1.131" "192.168.1.132" "192.168.1.133")

port=2222

for ip in "${containers[@]}"; do
	for i in {1..10}; do
		echo "[$i/10] Connect to $ip ..."
		ssh -p "$port" "$ip"
	done
done
