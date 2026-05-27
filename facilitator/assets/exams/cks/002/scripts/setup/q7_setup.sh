#!/bin/bash
# Setup for Question 7: Falco Custom Rules ConfigMap

# Create namespace
kubectl create namespace falco-config 2>/dev/null || true

echo "Setup completed for Question 7"
exit 0
