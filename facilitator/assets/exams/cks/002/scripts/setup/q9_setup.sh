#!/bin/bash
# Setup for Question 9: Namespace Isolation NetworkPolicy

# Create namespace
kubectl create namespace isolated-app 2>/dev/null || true

echo "Setup completed for Question 9"
exit 0
