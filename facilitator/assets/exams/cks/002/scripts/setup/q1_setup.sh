#!/bin/bash
# Setup for Question 1: AppArmor Profile Pod

# Create namespace
kubectl create namespace apparmor-ns 2>/dev/null || true

echo "Setup completed for Question 1"
exit 0
