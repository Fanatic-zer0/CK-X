#!/bin/bash
# Q6 Setup: Create apparmor-workloads namespace
set -e

kubectl create namespace apparmor-workloads --dry-run=client -o yaml | kubectl apply -f -

echo "Q6 setup complete: apparmor-workloads namespace created"
