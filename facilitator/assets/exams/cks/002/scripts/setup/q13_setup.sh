#!/bin/bash
# Setup for Question 13: Fully Hardened Pod

# Create namespace
kubectl create namespace hardened-pod-ns 2>/dev/null || true

echo "Setup completed for Question 13"
exit 0
