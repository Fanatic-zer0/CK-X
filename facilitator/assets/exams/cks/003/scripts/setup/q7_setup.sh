#!/bin/bash
# Q7 Setup: Create binary-verification namespace
set -e

kubectl create namespace binary-verification --dry-run=client -o yaml | kubectl apply -f -

echo "Q7 setup complete: binary-verification namespace created"
