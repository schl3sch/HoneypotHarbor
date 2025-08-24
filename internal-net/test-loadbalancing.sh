#!/bin/bash

NGINX_IP="192.168.1.112"

echo "Frontend Load Test (HTTP /)"
for i in {1..1000}
do
    curl -s http://$NGINX_IP/ -o /dev/null
    echo 
done

echo "API Test (/api/)"
sleep 2

for i in {1..1000}
do
    curl -s http://$NGINX_IP/api/ -o /dev/null
    echo 
done
