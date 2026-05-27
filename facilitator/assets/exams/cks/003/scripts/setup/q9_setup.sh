#!/bin/bash
# Q9 Setup: Create policy-config namespace
set -e

kubectl create namespace policy-config --dry-run=client -o yaml | kubectl apply -f -

echo "Q9 setup complete: policy-config namespace created"
