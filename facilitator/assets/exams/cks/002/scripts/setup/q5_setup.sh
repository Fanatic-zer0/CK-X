#!/bin/bash
# Setup for Question 5: RuntimeClass for Sandbox Containers

# Create namespace
kubectl create namespace sandbox-workloads 2>/dev/null || true

echo "Setup completed for Question 5"
exit 0
