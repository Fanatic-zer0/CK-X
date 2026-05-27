#!/bin/bash
# Setup for Question 3: Default ServiceAccount Restriction

# Create namespace
kubectl create namespace sa-restrict 2>/dev/null || true

echo "Setup completed for Question 3"
exit 0
