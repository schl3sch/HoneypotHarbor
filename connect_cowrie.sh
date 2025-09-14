#!/bin/bash

containers=("192.168.1.131" "192.168.1.132" "192.168.1.133")

port=2222

for ip in "${containers[@]}"; do
	echo "Verbinde zu $ip ..."
	ssh -p "$port" "$ip"
done
