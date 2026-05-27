#!/bin/bash
# Q14 Setup: Create cloud-workloads namespace
set -e

kubectl create namespace cloud-workloads --dry-run=client -o yaml | kubectl apply -f -

echo "Q14 setup complete: cloud-workloads namespace created"
