#!/bin/bash
# Setup for Question 4: Prevent Privilege Escalation

# Create namespace
kubectl create namespace hardened-ns 2>/dev/null || true

echo "Setup completed for Question 4"
exit 0
